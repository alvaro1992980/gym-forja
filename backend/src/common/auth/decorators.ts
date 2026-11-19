import { createParamDecorator, ExecutionContext, SetMetadata } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { Request } from 'express';
import { AuthUser } from './auth-user';

export const IS_PUBLIC_KEY = 'auth:isPublic';
export const ROLES_KEY = 'auth:roles';
export const ALLOW_PASSWORD_CHANGE_PENDING_KEY = 'auth:allowPasswordChangePending';

/** No access token required (login, refresh, health). */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);

/** Only these roles may call the route (RolesGuard). Without it, any authenticated user may. */
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);

/**
 * Allowed even when `mustChangePassword` is true (section 8.1 allow-list:
 * change-password, logout and me).
 */
export const AllowWhenPasswordChangeRequired = () =>
  SetMetadata(ALLOW_PASSWORD_CHANGE_PENDING_KEY, true);

export const ALLOW_INACTIVE_KEY = 'auth:allowInactive';

/**
 * A valid access token of a deactivated account still reaches this route, so the handler
 * can record the attempt ([R-21] check-in with a stale session). Every other route answers
 * 401 for deactivated accounts [R-43].
 */
export const AllowInactiveAccount = () => SetMetadata(ALLOW_INACTIVE_KEY, true);

/** The authenticated user. Only valid on non-public routes. */
export const CurrentUser = createParamDecorator((_data: unknown, ctx: ExecutionContext) => {
  const req = ctx.switchToHttp().getRequest<Request & { user?: AuthUser }>();
  return req.user;
});
