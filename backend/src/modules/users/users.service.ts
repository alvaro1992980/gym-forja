import { HttpStatus, Injectable } from '@nestjs/common';
import { Prisma, Role, User } from '@prisma/client';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { mapUserUniqueViolation } from '../../common/errors/prisma-errors';
import { generateTemporaryPassword, hashPassword } from '../../common/security/password';
import { PrismaService } from '../../prisma/prisma.service';
import { TokensService } from '../auth/tokens.service';

export interface NewUserData {
  role: Role;
  firstName: string;
  lastName: string;
  phone: string; // already normalized [R-40]
  email?: string | null;
  birthDate?: Date | null;
  gender?: string | null;
  emergencyContact?: string | null;
  medicalNotes?: string | null;
}

export interface CreatedUser {
  user: User;
  /** [R-41] Returned once to the admin; never stored in plain text. */
  temporaryPassword: string;
}

type Db = PrismaService | Prisma.TransactionClient;

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly tokens: TokensService,
  ) {}

  /**
   * [R-41] Creates an account with a generated temporary password and
   * mustChangePassword = true. Pass a transaction client to combine with other writes.
   * Throws PHONE_ALREADY_EXISTS / EMAIL_ALREADY_EXISTS (409).
   */
  async createWithTemporaryPassword(data: NewUserData, db: Db = this.prisma): Promise<CreatedUser> {
    const temporaryPassword = generateTemporaryPassword();
    const passwordHash = await hashPassword(temporaryPassword);
    try {
      const user = await db.user.create({
        data: {
          ...data,
          email: data.email ? data.email.trim().toLowerCase() : null,
          passwordHash,
          mustChangePassword: true,
          isActive: true,
        },
      });
      return { user, temporaryPassword };
    } catch (error) {
      mapUserUniqueViolation(error);
    }
  }

  /** Pre-check so a transaction is not started for an obvious duplicate. */
  async assertPhoneAndEmailFree(phone: string, email?: string | null): Promise<void> {
    if (await this.prisma.user.findUnique({ where: { phone }, select: { id: true } })) {
      throw new AppException(HttpStatus.CONFLICT, ErrorCode.PHONE_ALREADY_EXISTS);
    }
    const normalizedEmail = email?.trim().toLowerCase();
    if (
      normalizedEmail &&
      (await this.prisma.user.findUnique({
        where: { email: normalizedEmail },
        select: { id: true },
      }))
    ) {
      throw new AppException(HttpStatus.CONFLICT, ErrorCode.EMAIL_ALREADY_EXISTS);
    }
  }

  /**
   * [R-43] Deactivate: isActive = false and every refresh token revoked.
   * [R-45] Rejected when it would leave no active ADMIN. Admin rows are locked
   * (SELECT … FOR UPDATE) so two concurrent deactivations cannot both pass the check.
   */
  async deactivate(userId: string): Promise<User> {
    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({ where: { id: userId } });
      if (!user) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      if (!user.isActive) return user;

      if (user.role === Role.ADMIN) {
        const activeAdmins = await tx.$queryRaw<{ id: string }[]>`
          SELECT id FROM "User" WHERE role = 'ADMIN' AND "isActive" = true FOR UPDATE`;
        if (activeAdmins.filter((a) => a.id !== userId).length === 0) {
          throw new AppException(HttpStatus.CONFLICT, ErrorCode.LAST_ACTIVE_ADMIN);
        }
      }

      const updated = await tx.user.update({ where: { id: userId }, data: { isActive: false } });
      await this.tokens.revokeAllForUser(userId, tx);
      return updated;
    });
  }

  async reactivate(userId: string): Promise<User> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    if (user.isActive) return user;
    return this.prisma.user.update({ where: { id: userId }, data: { isActive: true } });
  }

  /** [R-44] New temporary password, mustChangePassword = true, all sessions revoked. */
  async resetPassword(userId: string): Promise<CreatedUser> {
    const temporaryPassword = generateTemporaryPassword();
    const passwordHash = await hashPassword(temporaryPassword);
    return this.prisma.$transaction(async (tx) => {
      const exists = await tx.user.findUnique({ where: { id: userId }, select: { id: true } });
      if (!exists) throw new AppException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      const user = await tx.user.update({
        where: { id: userId },
        data: { passwordHash, mustChangePassword: true },
      });
      await this.tokens.revokeAllForUser(userId, tx);
      return { user, temporaryPassword };
    });
  }
}
