import { INestApplication } from '@nestjs/common';
import { Role, User } from '@prisma/client';
import request from 'supertest';
import type { App } from 'supertest/types';
import { hashPassword } from '../../src/common/security/password';
import { PrismaService } from '../../src/prisma/prisma.service';
import { seedBase } from '../../prisma/seed-core';

export const SEED_ADMIN = {
  phone: '+59170000000',
  password: 'SeedPass123',
};

/** Runs the real seed against the test database. */
export async function seedTestBase(prisma: PrismaService) {
  return seedBase(prisma, {
    SEED_ADMIN_PHONE: SEED_ADMIN.phone,
    SEED_ADMIN_PASSWORD: SEED_ADMIN.password,
    GYM_TIMEZONE: 'America/La_Paz',
  });
}

let phoneCounter = 0;
/** A unique, valid Bolivian phone per call within a test run. */
export function uniquePhone(): string {
  phoneCounter += 1;
  return `+5917${String(1_000_000 + phoneCounter).slice(-7)}`;
}

export const DEFAULT_PASSWORD = 'Password123';

/** Creates a user directly in the database (test fixture, password already changed). */
export async function createUser(
  prisma: PrismaService,
  data: Partial<Omit<User, 'passwordHash'>> & { role: Role; password?: string },
): Promise<User & { password: string }> {
  const { password = DEFAULT_PASSWORD, ...rest } = data;
  const user = await prisma.user.create({
    data: {
      firstName: 'Test',
      lastName: rest.role,
      phone: uniquePhone(),
      mustChangePassword: false,
      ...rest,
      passwordHash: await hashPassword(password),
    },
  });
  return { ...user, password };
}

export interface Session {
  accessToken: string;
  refreshToken: string;
  user: { id: string; role: Role; mustChangePassword: boolean };
}

export async function login(
  app: INestApplication<App>,
  phone: string,
  password: string,
): Promise<Session> {
  const res = await request(app.getHttpServer())
    .post('/api/v1/auth/login')
    .send({ phone, password })
    .expect(200);
  return res.body as Session;
}

/** Creates a user and logs in. */
export async function createAndLogin(
  app: INestApplication<App>,
  prisma: PrismaService,
  role: Role,
  extra: Partial<Omit<User, 'passwordHash'>> = {},
): Promise<{ user: User & { password: string }; session: Session }> {
  const user = await createUser(prisma, { role, ...extra });
  return { user, session: await login(app, user.phone, user.password) };
}

export function bearer(token: string): [string, string] {
  return ['Authorization', `Bearer ${token}`];
}

export interface CreatedMember {
  id: string;
  phone: string;
  temporaryPassword: string;
  membership: { tier: string; startDate: string; endDate: string; daysLeft: number };
  payments: { id: string; kind: string; amount: string }[];
}

/** POST /admin/members with sensible defaults (BASIC, 1 month, suggested amount, CASH). */
export async function createMemberViaApi(
  app: INestApplication<App>,
  adminToken: string,
  body: Record<string, unknown> = {},
): Promise<CreatedMember> {
  const res = await request(app.getHttpServer())
    .post('/api/v1/admin/members')
    .set(...bearer(adminToken))
    .send({
      firstName: 'Juan',
      lastName: 'Pérez',
      phone: uniquePhone(),
      tier: 'BASIC',
      months: 1,
      amount: 150,
      method: 'CASH',
      ...body,
    })
    .expect(201);
  return res.body as CreatedMember;
}

/** Logs in with the temporary password and sets DEFAULT_PASSWORD, returning a usable session. */
export async function activateMember(
  app: INestApplication<App>,
  member: CreatedMember,
): Promise<Session> {
  const first = await login(app, member.phone, member.temporaryPassword);
  await request(app.getHttpServer())
    .post('/api/v1/auth/change-password')
    .set(...bearer(first.accessToken))
    .send({ currentPassword: member.temporaryPassword, newPassword: DEFAULT_PASSWORD })
    .expect(204);
  return login(app, member.phone, DEFAULT_PASSWORD);
}
