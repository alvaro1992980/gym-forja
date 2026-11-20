# Gym App

Mobile app for a single gym: members check in by scanning a rotating QR at the door, admins manage
memberships and payments, and PLUS/PREMIUM members follow training plans.

| Folder | What |
|---|---|
| [`backend/`](backend/) | NestJS API + PostgreSQL (Prisma). |
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

NestJS 11 + Prisma 6 + PostgreSQL. Needs the database from step 1.

```bash
cd backend
npm ci
cp .env.example .env          # then edit: secrets, SEED_ADMIN_PHONE / SEED_ADMIN_PASSWORD
npx prisma migrate dev        # apply migrations to the dev DB (also generates the Prisma client)
npx prisma db seed            # gym settings, placeholder tier prices, first ADMIN (safe to re-run)
npm run start:dev             # http://localhost:3000/api/v1 (reloads on file changes)
```

| URL | What |
|---|---|
| `http://localhost:3000/api/v1/health` | `{"status":"ok","db":"ok"}` when the API and database are up |
| `http://localhost:3000/api/docs` | Swagger UI (off in production unless `SWAGGER_ENABLED=true`) |
| `http://localhost:3000/api/docs-json` | OpenAPI document |

Every variable is documented in [`backend/.env.example`](backend/.env.example). The API refuses
to start if a required variable is missing or invalid, and prints which one.

The seeded admin logs in with `SEED_ADMIN_PHONE` / `SEED_ADMIN_PASSWORD` and must change the
password on first login (login arrives in D2).

Tests:

```bash
npm run test                  # unit tests (no database needed)
npm run test:e2e              # e2e tests against DATABASE_URL_TEST (the gym_test DB);
                              # migrations are applied and tables emptied automatically
```

## 3. Mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define-from-file=config/dev.json   # emulator running or phone on USB
```

The backend must be running (section 2). Log in with the seeded admin
(`SEED_ADMIN_PHONE` without the `+591`, e.g. `70000000`, and `SEED_ADMIN_PASSWORD`).

### Environments (run configurations)

The app reads `APP_ENV` and `API_BASE_URL` at build time (`lib/core/config/app_config.dart`).
Each environment has a file in `mobile/config/`:

| Environment | Command | `API_BASE_URL` |
|---|---|---|
| dev | `flutter run --dart-define-from-file=config/dev.json` | `http://10.0.2.2:3000` (the Android emulator's address for your PC) |
| staging | `flutter run --dart-define-from-file=config/staging.json` | placeholder until a staging server exists |
| prod | `flutter run --release --dart-define-from-file=config/prod.json` | placeholder until production exists (D14) |

VS Code has the same three as launch configurations (`.vscode/launch.json`: *mobile (dev)*,
*mobile (staging)*, *mobile (prod)*). Without any define the app uses the dev values.

**Real phone on the same Wi-Fi:** override the URL with your PC's LAN IP, e.g.
`flutter run --dart-define-from-file=config/dev.json --dart-define=API_BASE_URL=http://192.168.1.20:3000`,
and allow port 3000 through the PC firewall. Plain HTTP is allowed only in debug builds.

**Testing token refresh:** set `JWT_ACCESS_TTL=1m` in `backend/.env`, restart the backend, log in,
wait over a minute and use the app: the next request gets `401`, the app refreshes the token and
retries without logging you out.

### Code generation

Models (freezed/json_serializable), Riverpod providers and translations are generated. The
generated files are committed, so a fresh clone runs as is. After changing an annotated class
or an `.arb` file:

```bash
dart run build_runner build      # *.g.dart, *.freezed.dart
flutter gen-l10n                 # lib/l10n/generated/ (also runs on flutter run/test)
```

UI text lives in `lib/l10n/app_es.arb` (default) and `app_en.arb`; never hard-code strings.

### Integration test (real backend, emulator)

`mobile/integration_test/` drives the real app against a running backend: it logs in as the
seeded admin (who must still have to change the password), creates members, renews, changes tier,
voids, resets a password, deactivates, filters the list and creates staff. Run it against a
throwaway database, never the dev one. For example, with the backend started on `gym_test`:

```bash
# backend/: fresh QA data (truncate gym_test first, e.g. by running npm run test:e2e)
DATABASE_URL=<DATABASE_URL_TEST> npx prisma migrate deploy
DATABASE_URL=<DATABASE_URL_TEST> SEED_ADMIN_PASSWORD=QaSeed1234 npx prisma db seed
DATABASE_URL=<DATABASE_URL_TEST> npm run start:dev

# mobile/: clear the app's data first (adb shell pm clear com.example.gym_app)
flutter test integration_test -d emulator-5554 --dart-define-from-file=config/dev.json \
  --dart-define=QA_ADMIN_PHONE=70000000 --dart-define=QA_ADMIN_PASSWORD=QaSeed1234
```

`integration_test/checkin_flow_test.dart` (D7) runs the check-in flow on one device playing
kiosk, member and admin in turn: it creates a kiosk and members through the API, reads the QR
from the kiosk screen and feeds it to the member scanner (no camera needed), and checks the
admin socket and the live screen. `integration_test/notifications_flow_test.dart` (D8) checks the
inbox, bell and notification taps (backend with `PUSH_ENABLED=false`). Run one file at a time (`flutter test
integration_test/<file>.dart ...`), clearing the app's data before each run.

## 4. Quality gates

Run these before every commit (see section 0.8 of the [plan](docs/PLAN.md)):

```bash
# Backend
cd backend && npm run lint && npm run test && npm run test:e2e && npm run build

# Mobile
cd mobile && flutter analyze && flutter test && dart format --set-exit-if-changed .
```

## Working on this project

Development follows [`docs/PLAN.md`](docs/PLAN.md), one deliverable at a time. Progress is tracked
in [`docs/PROGRESS.md`](docs/PROGRESS.md). Never commit `.env` files, keystores or Firebase config
files; they are git-ignored. Push notifications stay off until the Firebase files are added, as
described in [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md).
