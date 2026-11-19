import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Prisma, User } from '@prisma/client';
import { createHash, randomBytes } from 'node:crypto';
import { AccessTokenPayload } from '../../common/auth/auth-user';
import { ClockService } from '../../common/clock/clock.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { AppConfigService } from '../../config/app-config.service';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthResponseDto } from './dto';

const MS_PER_DAY = 24 * 60 * 60 * 1000;

/** Refresh tokens are random (256 bits); only their SHA-256 is stored (section 8.1). */
export function hashRefreshToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

type Db = PrismaService | Prisma.TransactionClient;

@Injectable()
export class TokensService {
  private readonly logger = new Logger(TokensService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly clock: ClockService,
    private readonly config: AppConfigService,
  ) {}

  /** New access + refresh token pair for a user. */
  async issue(user: User, db: Db = this.prisma): Promise<AuthResponseDto> {
    const payload: AccessTokenPayload = { sub: user.id, role: user.role, typ: 'access' };
    const accessToken = await this.jwt.signAsync(payload);

    const refreshToken = randomBytes(32).toString('base64url');
    const ttlDays = this.config.get('JWT_REFRESH_TTL_DAYS');
    await db.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: hashRefreshToken(refreshToken),
        expiresAt: new Date(this.clock.now().getTime() + ttlDays * MS_PER_DAY),
      },
    });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        role: user.role,
        firstName: user.firstName,
        lastName: user.lastName,
        mustChangePassword: user.mustChangePassword,
      },
    };
  }

  /**
   * Rotation with reuse detection (section 10):
   *  - valid token → revoked and replaced by a new pair;
   *  - an already revoked token → treated as stolen: every token of that user is revoked;
   *  - unknown/expired token or inactive user → 401.
   */
  async rotate(refreshToken: string): Promise<AuthResponseDto> {
    const now = this.clock.now();
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash: hashRefreshToken(refreshToken) },
      include: { user: true },
    });
    if (!stored) throw this.invalid();

    if (stored.revokedAt) {
      await this.revokeAllForUser(stored.userId);
      this.logger.warn(
        `Refresh token reuse detected for user ${stored.userId}; all sessions revoked`,
      );
      throw this.invalid();
    }
    if (stored.expiresAt <= now) throw this.invalid();
    if (!stored.user.isActive) {
      await this.revokeAllForUser(stored.userId);
      throw new AppException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_INACTIVE);
    }

    const result = await this.prisma.$transaction(async (tx) => {
      // Conditional update: if two requests race with the same token, only one wins.
      const { count } = await tx.refreshToken.updateMany({
        where: { id: stored.id, revokedAt: null },
        data: { revokedAt: now },
      });
      if (count === 0) return null;
      return this.issue(stored.user, tx);
    });

    if (!result) {
      await this.revokeAllForUser(stored.userId);
      this.logger.warn(`Concurrent refresh token reuse for user ${stored.userId}; all revoked`);
      throw this.invalid();
    }
    return result;
  }

  /** Revokes one refresh token if it belongs to the user (logout). Unknown tokens are ignored. */
  async revoke(userId: string, refreshToken: string): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: { userId, tokenHash: hashRefreshToken(refreshToken), revokedAt: null },
      data: { revokedAt: this.clock.now() },
    });
  }

  /** [R-43] / [R-44] Ends every session of a user. */
  async revokeAllForUser(userId: string, db: Db = this.prisma): Promise<void> {
    await db.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: this.clock.now() },
    });
  }

  private invalid(): AppException {
    return new AppException(HttpStatus.UNAUTHORIZED, ErrorCode.INVALID_REFRESH_TOKEN);
  }
}
