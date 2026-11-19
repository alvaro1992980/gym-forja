# Progress

| Deliverable | Status | Date | Notes |
|---|---|---|---|
| D0 Repo & tooling | ✅ | 2026-11-19 | Monorepo created; fresh Flutter app in `mobile/`; Postgres 16 via compose (host port 5433, `gym` + `gym_test` DBs); README, docs, lint tooling. |
| D1 Backend foundation | ✅ | 2026-11-19 | NestJS 11 + Prisma 6 API skeleton: typed config, core migration, error format, pino logs, helmet/CORS/throttler, Swagger, `/health`, `gym-date.ts` + `ClockService`, seed. 77 unit + 8 e2e tests. |
| D2 Auth & users | ✅ | 2026-11-19 | Login/refresh (rotation + reuse detection)/logout/change-password/`/me`; global JWT, must-change-password and roles guards; phone normalization; temporary passwords; staff endpoints with [R-45]; login rate limit. |
| D3 Memberships & payments | ✅ | 2026-11-19 | Members CRUD + filters, renewals with preview, tier changes (prorated upgrade, downgrade warning, scheduled tier), voids with recalculation, pricing, settings, `/me/membership`, `/me/payments`. Every [R-01]–[R-16] tested. |
| D4 Mobile foundation | ✅ | 2026-11-19 | Flutter app shell: Riverpod + go_router role redirects, dio client with token refresh, secure session storage, splash/login/change-password/logout, M3 theme, tier badge, state widgets, es/en localization, dev/staging/prod run configs. Verified on an Android emulator against the real backend. |
| D5 Admin member UI | ✅ | 2026-11-19 | Admin bottom nav; members list (search, filters, paging), new-member stepper with one-time temporary password (copy/share), member detail, renew, tier change, void, edit, reset password, deactivate; Precios, Personal (staff creation), Configuración. Full flow verified on the emulator against the real backend. |
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

## D4 — Mobile foundation

- [x] Dependencies from 5.3 for the foundation (riverpod + riverpod_generator, go_router, dio, flutter_secure_storage, freezed, json_serializable, build_runner, intl, flutter_localizations, mocktail); feature plugins come with their deliverables (see DECISIONS)
- [x] `core/config`: `APP_ENV` + `API_BASE_URL` via `--dart-define-from-file=config/{dev,staging,prod}.json`, VS Code launch configs, documented in the README
- [x] dio client + `AuthInterceptor`: attaches the token, refreshes once on `401`, queues concurrent requests behind one refresh, logs out when the refresh token is rejected
- [x] Error mapping from every backend `code` to localized messages (`core/network/error_messages.dart`)
- [x] Secure token storage, `SessionController`; splash → `/me` → route by role (Retry when offline)
- [x] Login (phone with +591 prefix selector [R-40], show/hide password), forced change password (strength hint), logout
- [x] go_router with role redirects and placeholder homes for ADMIN / TRAINER / MEMBER / KIOSK
- [x] Material 3 theme (light/dark), `TierBadge`, `LoadingView` / `ErrorView` / `EmptyView`
- [x] `app_es.arb` (default) + `app_en.arb`; no hard-coded UI strings
- [x] Acceptance: on the Android emulator (Pixel 9), the seeded admin logs in → forced password change → admin home (real backend)
- [x] Acceptance: closing (force-stop) and reopening the app keeps the session
- [x] Acceptance: with `JWT_ACCESS_TTL=1m`, after the token expired the reopened app went straight to the admin home; backend log: `GET /me 401 → POST /auth/refresh 200 → GET /me 200`
- [x] Verification: `flutter analyze` (no issues), `flutter test` (45: login form validation, splash routing, interceptor, redirects, validators, error mapping), `dart format --set-exit-if-changed .`

Done: the app shell talks to the real backend with a persistent, self-refreshing session and
routes each role to its own (placeholder) home.

## D5 — Admin: member management UI

- [x] Admin shell with bottom nav (Dashboard · Socios · Ingresos · Planes · Más); Dashboard/Ingresos/Planes are placeholders until D9/D7/D11
- [x] 9.3 #2 Members list: search (debounced), chips Activos / Por vencer / Vencidos / Inactivos + tier, rows with tier badge, "12 días" / "Vencido hace 3 días" / "Inactivo", last check-in, infinite scroll, pull-to-refresh, FAB "Nuevo socio"
- [x] 9.3 #3 New member stepper (personal data → tier with price, months 1/2/3/6/12 or other, start date within [R-05] → preview + amount/method/note [R-10] → summary) and the temporary password screen (shown once, Copiar, Compartir por WhatsApp)
- [x] 9.3 #4 Member detail: header (days-left ring, tier, status, call/WhatsApp), tabs Membresía / Pagos (void) / Ingresos / Datos (edit, reset password, deactivate/reactivate)
- [x] 9.3 #5 Renew: tier + months → preview period and suggested amount → amount, method, note; scheduled tier with "apply now" [R-09]
- [x] 9.3 #6 Tier change: upgrade shows the prorated suggestion [R-13], downgrade the warning [R-14] (+ trainer removal from PREMIUM [R-16])
- [x] Más → Precios [R-11], Personal (list, role filter, inactive toggle, create ADMIN/TRAINER/KIOSK, deactivate [R-45]), Configuración (time zone read-only), Mi perfil, Cerrar sesión
- [x] Acceptance: create a member with the stepper; temporary password shown once with copy/share (widget test + emulator)
- [x] Acceptance: list filters (active/expiring/expired/inactive/tier) and search work against the backend (emulator)
- [x] Acceptance: renew shows the correct new period from the preview before confirming ([R-07] early: day after endDate; [R-08] late: today; emulator)
- [x] Acceptance: upgrade shows the prorated suggestion; downgrade shows the warning (widget tests + emulator)
- [x] Acceptance: void asks for a reason and refreshes the member's dates (voiding the renewal restored the previous endDate on the emulator)
- [x] Acceptance: create a TRAINER and a KIOSK account (widget tests + emulator)
- [x] Verification: `flutter analyze` (no issues), `flutter test` (77), `dart format --set-exit-if-changed .`; integration test on the emulator passed

Done: the admin can run memberships from the phone. Found and fixed on the way: full-width
`FilledButton` theme broke buttons inside rows, and the two tab FABs shared a hero tag.

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

### D4
- [x] Emulator, dev config: login screen → seeded admin (`70000000`) → change password (strength hint shown) → "Administración" home with snackbar
- [x] Force-stop + reopen after > 1 min with `JWT_ACCESS_TTL=1m` → admin home without logging in again
- [x] Logout → `POST /auth/logout` 204 → login screen
- [x] Dev DB restored afterwards (admin back to the seed password with `mustChangePassword = true`)
- [ ] Real Android phone on the LAN (`--dart-define=API_BASE_URL=http://<PC IP>:3000`); only the emulator was used
- [ ] Spanish UI check on a device set to Spanish (the emulator was in English; widget tests cover the strings)

### D5
Run as `integration_test/admin_members_flow_test.dart` on the Pixel 9 emulator against the real
backend on the `gym_test` database (dev DB untouched), plus a visual check of the list, detail
and payments screens:
- [x] Create member (stepper → temporary password → detail)
- [x] Renew early (new period starts the day after `endDate`)
- [x] Renew late (expired member; new period starts today)
- [x] Upgrade (prorated suggestion shown) and downgrade (warning shown)
- [x] Void (reason required; `endDate` back to the previous value)
- [x] Deactivate, reset password
- [x] Filters and search; create TRAINER and KIOSK
- [ ] Same flow on a physical Android phone