# Progress

| Deliverable | Status | Date | Notes |
|---|---|---|---|
| D0 Repo & tooling | ✅ | 2026-11-19 | Monorepo created; fresh Flutter app in `mobile/`; Postgres 16 via compose (host port 5433, `gym` + `gym_test` DBs); README, docs, lint tooling. |
| D1 Backend foundation | ✅ | 2026-11-19 | NestJS 11 + Prisma 6 API skeleton: typed config, core migration, error format, pino logs, helmet/CORS/throttler, Swagger, `/health`, `gym-date.ts` + `ClockService`, seed. 77 unit + 8 e2e tests. |
| D2 Auth & users | ⬜ | | |
| D3 Memberships & payments | ⬜ | | |
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
