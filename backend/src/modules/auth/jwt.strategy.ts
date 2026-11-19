import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AccessTokenPayload, AuthUser } from '../../common/auth/auth-user';
import { AppConfigService } from '../../config/app-config.service';
import { PrismaService } from '../../prisma/prisma.service';

/**
 * Verifies the access token, then loads the user on every request so that deactivation
 * [R-43] and the end of mustChangePassword take effect immediately, not after 15 minutes.
 * Inactive users are rejected by JwtAuthGuard, except on @AllowInactiveAccount() routes.
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    config: AppConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get('JWT_ACCESS_SECRET'),
      algorithms: ['HS256'],
    });
  }

  async validate(payload: AccessTokenPayload): Promise<AuthUser | false> {
    if (payload.typ !== 'access' || typeof payload.sub !== 'string') return false;
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: {
        id: true,
        role: true,
        firstName: true,
        lastName: true,
        mustChangePassword: true,
        isActive: true,
      },
    });
    if (!user) return false;
    return {
      id: user.id,
      role: user.role,
      firstName: user.firstName,
      lastName: user.lastName,
      mustChangePassword: user.mustChangePassword,
      isActive: user.isActive,
    };
  }
}
