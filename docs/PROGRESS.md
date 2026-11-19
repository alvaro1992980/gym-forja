# Progress

| Deliverable | Status | Date | Notes |
|---|---|---|---|
| D0 Repo & tooling | ✅ | 2026-11-19 | Monorepo created; fresh Flutter app in `mobile/`; Postgres 16 via compose (host port 5433, `gym` + `gym_test` DBs); README, docs, lint tooling. |
| D1 Backend foundation | ⬜ | | |
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

## Manual QA checklists

### D0
- [x] Fresh clone → `docker compose up -d` → `docker compose ps` shows `(healthy)`
- [x] `gym` and `gym_test` databases exist
- [x] Fresh clone → `cd backend && npm ci && npm run lint:check && npm run format:check`
- [x] Fresh clone → `cd mobile && flutter pub get && flutter analyze && flutter test`
