# Progress

| Deliverable | Status | Date | Notes |
|---|---|---|---|
| D0 Repo & tooling | ✅ | 2026-11-19 | Monorepo created; fresh Flutter app in `mobile/`; Postgres 16 via compose (host port 5433, `gym` + `gym_test` DBs); README, docs, lint tooling. |
| D1 Backend foundation | ✅ | 2026-11-19 | NestJS 11 + Prisma 6 API skeleton: typed config, core migration, error format, pino logs, helmet/CORS/throttler, Swagger, `/health`, `gym-date.ts` + `ClockService`, seed. 77 unit + 8 e2e tests. |
| D2 Auth & users | ✅ | 2026-11-19 | Login/refresh (rotation + reuse detection)/logout/change-password/`/me`; global JWT, must-change-password and roles guards; phone normalization; temporary passwords; staff endpoints with [R-45]; login rate limit. |
| D3 Memberships & payments | ✅ | 2026-11-19 | Members CRUD + filters, renewals with preview, tier changes (prorated upgrade, downgrade warning, scheduled tier), voids with recalculation, pricing, settings, `/me/membership`, `/me/payments`. Every [R-01]–[R-16] tested. |
| D4 Mobile foundation | ⬜ | | |
| D5 Admin member UI | ⬜ | | |
| D6 Check-in backend | ⬜ | | |
| D7 Check-in mobile | ⬜ | | |
| D8 Notifications & scheduler | ⬜ | | |
| D9 Dashboard & reports | ⬜ | | |
| D10 v1 hardening & Android release | ⬜ | | |
| D11 Plans (PLUS) backend + builder | ⬜ | | |
| D12 Member workouts & progress | ⬜ | | |
| D13 Premium | ⬜ | | |
| D14 iOS & store release | ⬜ | | |

Status: ⬜ not started · 🟡 in progress · ✅ done (all acceptance criteria met)

## D0 — Repo & tooling

- [x] Monorepo structure from PLAN 5.1 (`backend/`, `mobile/`, `docs/`, `docker-compose.yml`, `README.md`)
- [x] Flutter project in `mobile/` (no existing project was found, so a new one was created; see DECISIONS)
- [x] `docker-compose.yml`: `postgres:16` with volume + healthcheck; optional `pgadmin` (profile `tools`)
- [x] Root `README.md`: prerequisites, DB, backend, mobile, tests
- [x] `docs/PROGRESS.md`, `docs/DECISIONS.md`, `docs/OPEN_QUESTIONS.md`
- [x] `.gitignore` (Node, Flutter, env, secrets, IDE), `.gitattributes`, `.editorconfig`
- [x] Backend Prettier + ESLint (flat config, typescript-eslint type-checked)
- [x] Mobile `analysis_options.yaml`: `flutter_lints` + strict casts/inference/raw types + extra rules
- [x] Acceptance: `docker compose up -d` → postgres `healthy`
- [x] Acceptance: README steps work on a fresh clone
- [x] Verification: `docker compose ps` healthy; `flutter analyze` → no issues (also `flutter test`, `dart format` pass)

Done: created the monorepo, docs and tooling. The plan file was renamed to `docs/PLAN.md` as it
instructs. The Android `applicationId` is still `com.example.gym_app` (OPEN_QUESTIONS #7).

## D1 — Backend foundation

- [x] NestJS app in `backend/` (strict TypeScript), global prefix `/api/v1`
- [x] Typed config validated at startup (`src/config/`); exits with a readable error when a variable is missing/invalid
- [x] `PrismaService` + first migration `init_core` with the 12 core models
- [x] Global `ValidationPipe` (whitelist + forbidNonWhitelisted), global exception filter (`{statusCode, code, message, details?}`), `error-codes.ts`
- [x] pino logs with request id (`X-Request-Id`), sensitive fields redacted; helmet; CORS from `CORS_ORIGINS`; throttler
- [x] Swagger at `/api/docs` (+ `/api/docs-json`)
- [x] `GET /api/v1/health` checks the database
- [x] `common/date/gym-date.ts` + `ClockService` (`FixedClockService` for tests), unit tests for [R-01]–[R-05]
- [x] Seed: GymSettings, TierPrices (150/250/400 BOB placeholders), first ADMIN from `SEED_ADMIN_*` (idempotent)
- [x] Acceptance: `npm run start:dev` → `/api/v1/health` returns `{"status":"ok","db":"ok"}`
- [x] Acceptance: Swagger loads (UI page and its JS/CSS assets return 200; OpenAPI lists `/api/v1/health`)
- [x] Acceptance: date helper tests cover all three [R-04] examples, including the month-end one, plus more month-end and leap-year cases
- [x] Verification: `npm run lint && npm run test && npm run build && npx prisma migrate dev && npx prisma db seed` (also `npm run test:e2e`)

Done: API foundation in place, with every gate passing. Prisma 6 and Nest 11 were chosen
deliberately, and the training/premium relations on `User` are deferred (see DECISIONS).

## D2 — Auth & users

- [x] `auth` module: `POST /auth/login`, `/auth/refresh` (rotation + reuse detection), `/auth/logout` (also removes the FCM device), `/auth/change-password`, `GET /me`
- [x] JWT strategy (user reloaded per request, so deactivation is immediate), `@Roles()` + `RolesGuard`, `@CurrentUser()`, `@Public()`
- [x] Global `MustChangePasswordGuard` with allow-list (change-password, logout, me)
- [x] Phone normalization [R-40] (`src/common/phone/phone.ts`) with tests
- [x] Temporary password generator [R-41] (8 chars, no 0/O/o/1/l/I) and argon2id hashing [R-42], with tests
- [x] `POST/GET /admin/staff` (+ `/admin/staff/:id/deactivate|reactivate`, see DECISIONS); [R-43] token revocation; [R-45] last admin
- [x] Login rate limit: 5/min per IP + phone
- [x] Acceptance: seeded admin logs in and must change the password first (e2e uses the real seed; also checked by hand on the dev DB)
- [x] Acceptance: a refresh token works once; reuse revokes all of that user's tokens (e2e)
- [x] Acceptance: TRAINER, MEMBER and KIOSK get `403` on `/admin/*`; anonymous gets `401` (e2e)
- [x] Verification: lint, test (111), test:e2e (49), build

Done: authentication and staff management. Access tokens are checked against the database on
every request, so deactivating a user or finishing the password change takes effect immediately.

## D3 — Memberships, payments, pricing, settings

- [x] `POST /admin/members`: user + membership + NEW payment in one transaction; `GET /admin/members/preview` for the new-member stepper
- [x] `GET /admin/members` (filters `q`, `tier`, `status`, `expiringWithinDays`, `trainerId`; sort `name|endDate|createdAt`; paginated), `GET/PATCH /admin/members/:id`, deactivate / reactivate / reset-password
- [x] Renewal preview + create (`kind=RENEWAL`) [R-07]–[R-10]; tier of a renewal applied now or scheduled [R-09]
- [x] Tier change preview + apply: prorated upgrade (`kind=UPGRADE`, months 0) [R-13], downgrade warning [R-14], history kept [R-15], trainer unassigned when leaving PREMIUM [R-16]
- [x] `POST /admin/payments/:id/void` with recalculation [R-12]; `GET /admin/payments` with filters and totals
- [x] `GET/PUT /admin/pricing` [R-11], `GET/PUT /admin/settings`
- [x] `GET /me/membership`, `GET /me/payments` (no notes, no voided)
- [x] Unit tests: rules module (renewals, amounts, proration, replay with 6+ recalculation scenarios), payment DTO validation [R-06]
- [x] Acceptance: every rule [R-01]–[R-16] has passing tests (unit and/or e2e; [R-40]–[R-45] too)
- [x] Acceptance: creating a member returns a temporary password that works for login (e2e)
- [x] Acceptance: voiding the last renewal restores the previous `endDate` (unit + e2e)
- [x] Verification: lint, test (169), test:e2e (110), build

Done: the full membership lifecycle on the backend. Added `Membership.nextTier` /
`nextTierStartDate` (migration `membership_next_tier`) so [R-09] can schedule a tier for a
future period (see DECISIONS).

## Manual QA checklists

### D0
- [x] Fresh clone → `docker compose up -d` → `docker compose ps` shows `(healthy)`
- [x] `gym` and `gym_test` databases exist
- [x] Fresh clone → `cd backend && npm ci && npm run lint:check && npm run format:check`
- [x] Fresh clone → `cd mobile && flutter pub get && flutter analyze && flutter test`

### D1
- [x] `docker compose up -d`, then in `backend/`: `npm ci`, `cp .env.example .env`, `npx prisma migrate dev`, `npx prisma db seed`
- [x] Seed run twice → second run reports "already exists" and changes nothing
- [x] `npm run start:dev` → `GET /api/v1/health` = `{"status":"ok","db":"ok"}` with an `X-Request-Id` header
- [x] Open `http://localhost:3000/api/docs` → Swagger UI loads
- [x] Unknown route → `404 {"statusCode":404,"code":"NOT_FOUND","message":"…"}`
- [x] Empty `JWT_ACCESS_SECRET` → the app refuses to start and names the variable

### D2
- [x] Dev DB: log in as the seeded admin (`70000000` / seed password) → `mustChangePassword: true`
- [x] Same token: `GET /me` → 200; `GET /admin/staff` → 403 `PASSWORD_CHANGE_REQUIRED`

### D3
- [x] Dev DB: migration `membership_next_tier` applied (`prisma migrate status` up to date); app boots, `/health` ok
- [x] Swagger lists the member, payment, pricing and settings endpoints
- [ ] By hand in Swagger (optional, covered by e2e): create member → renew early → renew late → upgrade → downgrade → void → deactivate → reset password