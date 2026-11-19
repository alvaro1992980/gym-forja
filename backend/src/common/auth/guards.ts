import { CanActivate, ExecutionContext, HttpStatus, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { Role } from '@prisma/client';
import type { Request } from 'express';
import { AppException } from '../errors/app.exception';
import { ErrorCode } from '../errors/error-codes';
import { AuthUser } from './auth-user';
import { ALLOW_PASSWORD_CHANGE_PENDING_KEY, IS_PUBLIC_KEY, ROLES_KEY } from './decorators';

function getMeta<T>(reflector: Reflector, key: string, ctx: ExecutionContext): T | undefined {
  return reflector.getAllAndOverride<T>(key, [ctx.getHandler(), ctx.getClass()]);
}

function getUser(ctx: ExecutionContext): AuthUser | undefined {
  return ctx.switchToHttp().getRequest<Request & { user?: AuthUser }>().user;
}

/** Global: every route needs a valid access token unless marked @Public(). */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  override canActivate(ctx: ExecutionContext) {
    if (getMeta<boolean>(this.reflector, IS_PUBLIC_KEY, ctx)) return true;
    return super.canActivate(ctx);
  }

  override handleRequest<TUser = AuthUser>(err: unknown, user: TUser | false): TUser {
    if (err || !user) {
      throw new AppException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHORIZED);
    }
    return user;
  }
}

/** Global: while `mustChangePassword` is true only allow-listed routes work (section 8.1). */
@Injectable()
export class MustChangePasswordGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    if (getMeta<boolean>(this.reflector, IS_PUBLIC_KEY, ctx)) return true;
    const user = getUser(ctx);
    if (!user?.mustChangePassword) return true;
    if (getMeta<boolean>(this.reflector, ALLOW_PASSWORD_CHANGE_PENDING_KEY, ctx)) return true;
    throw new AppException(HttpStatus.FORBIDDEN, ErrorCode.PASSWORD_CHANGE_REQUIRED);
  }
}

/** Global: enforces @Roles(). */
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    if (getMeta<boolean>(this.reflector, IS_PUBLIC_KEY, ctx)) return true;
    const roles = getMeta<Role[]>(this.reflector, ROLES_KEY, ctx);
    if (!roles || roles.length === 0) return true;
    const user = getUser(ctx);
    if (user && roles.includes(user.role)) return true;
    throw new AppException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
  }
}
