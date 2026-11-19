# Gym App

Mobile app for a single gym: members check in by scanning a rotating QR at the door, admins manage
memberships and payments, and PLUS/PREMIUM members follow training plans.

| Folder | What |
|---|---|
| [`backend/`](backend/) | NestJS API + PostgreSQL (Prisma). Scaffolded in D1; D0 only has lint/format tooling. |
| [`mobile/`](mobile/) | Flutter app (Android + iOS), one codebase for every role. |
| [`docs/`](docs/) | [Plan](docs/PLAN.md), [progress](docs/PROGRESS.md), [decisions](docs/DECISIONS.md), [open questions](docs/OPEN_QUESTIONS.md), [API](docs/API.md). |
| [`docker-compose.yml`](docker-compose.yml) | Local PostgreSQL 16 (+ optional pgAdmin). |

## Prerequisites

| Tool | Version | Check |
|---|---|---|
| Git | any recent | `git --version` |
| Docker Desktop (with Compose v2) | Compose ≥ 2.20 | `docker compose version` |
| Node.js | 22 LTS or newer | `node --version` |
| Flutter (stable channel) | Flutter ≥ 3.50 (Dart ≥ 3.14) | `flutter --version`, then `flutter doctor` |
| Android Studio / Android SDK | for the emulator or a USB-connected phone | `flutter doctor` |

iOS builds need a Mac with Xcode (see D14 in the plan).

## 1. Start the database

```bash
cp .env.example .env        # optional: only to change the defaults
docker compose up -d
docker compose ps           # STATUS must show "(healthy)"
```

This starts PostgreSQL 16 on **host port 5433** (not 5432, so it does not clash with a local
Postgres), user `gym`, password `gym`, with two databases:

| Database | Used by | Connection string |
|---|---|---|
| `gym` | development | `postgresql://gym:gym@localhost:5433/gym` |
| `gym_test` | backend e2e tests | `postgresql://gym:gym@localhost:5433/gym_test` |

`gym_test` is created by [`docker/postgres/init/`](docker/postgres/init/) the first time the data
volume is created. Other useful commands:

```bash
docker compose --profile tools up -d    # also start pgAdmin at http://localhost:5050
docker compose logs -f postgres         # follow the logs
docker compose down                     # stop (data is kept)
docker compose down -v                  # stop and DELETE all data
```

To reach the database from pgAdmin, register a server with host `postgres`, port `5432`,
user `gym`, password `gym`.

## 2. Backend

> The NestJS API is created in **D1**. Until then only the lint/format tooling exists.

```bash
cd backend
npm ci
npm run lint:check       # ESLint (typescript-eslint + Prettier)
npm run format:check     # Prettier
```

From D1 on, this section will also list `npm run start:dev`, migrations, seeding and tests.

## 3. Mobile

```bash
cd mobile
flutter pub get
flutter run              # with an emulator running or a phone connected via USB
```

Environment flavors (`--dart-define=API_BASE_URL=...` for dev/staging/prod) are added in **D4**.

## 4. Quality gates

Run these before every commit (see section 0.8 of the [plan](docs/PLAN.md)):

```bash
# Backend (full set from D1 on: lint, test, test:e2e, build)
cd backend && npm run lint && npm run format:check

# Mobile
cd mobile && flutter analyze && flutter test && dart format --set-exit-if-changed .
```

## Working on this project

Development follows [`docs/PLAN.md`](docs/PLAN.md), one deliverable at a time. Progress is tracked
in [`docs/PROGRESS.md`](docs/PROGRESS.md). Never commit `.env` files, keystores or Firebase config
files; they are git-ignored.
