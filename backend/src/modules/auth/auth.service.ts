import { HttpStatus, Injectable } from '@nestjs/common';
import { ClockService } from '../../common/clock/clock.service';
import { formatLocalDate } from '../../common/date/gym-date';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { getDummyHash, hashPassword, verifyPassword } from '../../common/security/password';
import { PrismaService } from '../../prisma/prisma.service';
import { toMembershipSummary } from '../memberships/membership-view';
import { AuthResponseDto, ChangePasswordDto, LoginDto, LogoutDto, MeResponseDto } from './dto';
import { TokensService } from './tokens.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly tokens: TokensService,
    private readonly clock: ClockService,
  ) {}

  async login(dto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.prisma.user.findUnique({ where: { phone: dto.phone } });
    // Always run argon2 so unknown phones take as long as wrong passwords.
    const ok = await verifyPassword(user?.passwordHash ?? (await getDummyHash()), dto.password);
    if (!user || !ok) {
      throw new AppException(HttpStatus.UNAUTHORIZED, ErrorCode.INVALID_CREDENTIALS);
    }
    if (!user.isActive) {
      throw new AppException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_INACTIVE);
    }
    return this.tokens.issue(user);
  }

  refresh(refreshToken: string): Promise<AuthResponseDto> {
    return this.tokens.rotate(refreshToken);
  }

  async logout(userId: string, dto: LogoutDto): Promise<void> {
    await this.tokens.revoke(userId, dto.refreshToken);
    if (dto.fcmToken) {
      await this.prisma.device.deleteMany({ where: { userId, fcmToken: dto.fcmToken } });
    }
  }

  async changePassword(userId: string, dto: ChangePasswordDto): Promise<void> {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    if (!(await verifyPassword(user.passwordHash, dto.currentPassword))) {
      throw new AppException(HttpStatus.BAD_REQUEST, ErrorCode.WRONG_CURRENT_PASSWORD);
    }
    if (dto.newPassword === dto.currentPassword) {
      throw new AppException(HttpStatus.BAD_REQUEST, ErrorCode.PASSWORD_UNCHANGED);
    }
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash: await hashPassword(dto.newPassword), mustChangePassword: false },
    });
  }

  async me(userId: string): Promise<MeResponseDto> {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      include: { membership: true },
    });
    return {
      id: user.id,
      role: user.role,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      email: user.email,
      mustChangePassword: user.mustChangePassword,
      birthDate: user.birthDate ? formatLocalDate(user.birthDate) : null,
      gender: user.gender,
      emergencyContact: user.emergencyContact,
      // medicalNotes are never returned to members (section 10).
      membership:
        user.role === 'MEMBER' && user.membership
          ? toMembershipSummary(user.membership, this.clock.today())
          : null,
    };
  }
}
