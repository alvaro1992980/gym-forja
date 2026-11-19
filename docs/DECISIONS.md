# Decisions

Choices made where the plan was unclear or silent (PLAN section 0.4). Newest at the bottom.

| Date | Question | Decision | Reason |
|---|---|---|---|
| 2026-11-19 | The plan file was `docs/GYM_APP_PLAN.md`, but the plan and CLAUDE.md refer to `docs/PLAN.md`. | Renamed it to `docs/PLAN.md`. | The plan header says "Save this file as: docs/PLAN.md". |
| 2026-11-19 | D0 says to move "the existing Flutter project" into `mobile/`, but the repo had none and none was found on the machine. | Created a new project with `flutter create --org com.example --project-name gym_app --platforms android,ios mobile`. | Simplest option. Only Android and iOS are targets. The `com.example` id is tracked in OPEN_QUESTIONS #7. If an existing project turns up, its `lib/` can replace this one before D4. |
| 2026-11-19 | Host port for Postgres. | Host port **5433** by default (`POSTGRES_PORT` in root `.env`); the container still uses 5432. | Port 5432 was already used on the dev machine, and a local Postgres often holds it. |
| 2026-11-19 | Where does the e2e test database (`DATABASE_URL_TEST`, PLAN section 11) live? | Same container, second database `gym_test`, created by `docker/postgres/init/01-create-test-db.sh` on first start. | No extra container. Suites can reset it freely. |
| 2026-11-19 | pgAdmin is "optional". | It is in compose under the `tools` profile: `docker compose up -d` starts only Postgres, and `--profile tools` adds pgAdmin. | Keeps the default start fast; pgAdmin is available on demand. |
| 2026-11-19 | D0 asks for Prettier + ESLint in the backend, but the NestJS app is created only in D1 (`nest new`). | D0 adds `backend/package.json` (lint/format scripts only), `.prettierrc`, `eslint.config.mjs` (same shape as the Nest CLI's flat config) and a strict `tsconfig.json`. In D1, generate the Nest app (e.g. `nest new` in a temp folder with `--skip-git`) and merge its files into `backend/`, keeping these configs. | Satisfies D0 without creating the D1 scaffold early. |
| 2026-11-19 | What does "strict" mean for `flutter_lints`? | `flutter_lints` + analyzer `strict-casts`, `strict-inference`, `strict-raw-types` + extra rules (see `mobile/analysis_options.yaml`). Generated files (`*.g.dart`, `*.freezed.dart`) are excluded. | Common strict baseline that still works with code generation. |
| 2026-11-19 | Line endings on Windows. | `.gitattributes` normalizes to LF (CRLF only for `.bat/.cmd/.ps1`); `.editorconfig` and Prettier use LF. | Prevents CRLF churn and Prettier `endOfLine` errors across OSes. |
