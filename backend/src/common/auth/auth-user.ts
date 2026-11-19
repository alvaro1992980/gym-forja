import { Role } from '@prisma/client';

/** The authenticated user attached to `request.user` by JwtStrategy (loaded from the DB). */
export interface AuthUser {
  id: string;
  role: Role;
  firstName: string;
  lastName: string;
  mustChangePassword: boolean;
}

/** Claims of an access token. */
export interface AccessTokenPayload {
  sub: string;
  role: Role;
  typ: 'access';
}
