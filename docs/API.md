# API

The API contract is specified in [PLAN.md, section 8](PLAN.md#8-api-specification-apiv1).
Live OpenAPI documentation (Swagger) is served by the backend:

- UI: `http://localhost:3000/api/docs`
- JSON: `http://localhost:3000/api/docs-json`
- Base path for every endpoint: `/api/v1`

## Conventions in place (D1)

- **Errors** always have the shape `{ statusCode, code, message, details? }`. `message` is in
  Spanish. Every `code` is listed in `backend/src/common/errors/error-codes.ts`.
  Validation errors are `400 VALIDATION_ERROR` with `details.fields = [{ field, constraints }]`.
- **Request id:** every response has an `X-Request-Id` header. A well-formed incoming
  `X-Request-Id` is reused, so client logs can be correlated with server logs.
- **Rate limit:** 120 requests per minute per client by default (`429 TOO_MANY_REQUESTS`).
  Stricter per-route limits come with login (D2) and check-in (D6).

## Endpoints

| Method | Path | Role | Since | Notes |
|---|---|---|---|---|
| GET | `/health` | public | D1 | `200 {status:"ok", db:"ok"}`; `503 {status:"error", db:"error"}` when the database is unreachable. Not rate-limited. |
| POST | `/auth/login` | public | D2 | `{phone, password}` → `{accessToken, refreshToken, user}`. Phone in any format [R-40]. 401 `INVALID_CREDENTIALS`, 403 `ACCOUNT_INACTIVE`, 429 after 5 attempts/min per IP+phone. |
| POST | `/auth/refresh` | public | D2 | `{refreshToken}` → same as login. Rotates; reusing a token revokes all of the user's tokens (401 `INVALID_REFRESH_TOKEN`). |
| POST | `/auth/logout` | any | D2 | `{refreshToken, fcmToken?}` → 204. |
| POST | `/auth/change-password` | any | D2 | `{currentPassword, newPassword}` → 204; clears `mustChangePassword`. 400 `WRONG_CURRENT_PASSWORD`, `PASSWORD_UNCHANGED`. |
| GET | `/me` | any | D2 | Profile (+ `membership {tier, startDate, endDate, daysLeft, status}` for members). |
| POST | `/admin/staff` | ADMIN | D2 | `{role: ADMIN\|TRAINER\|KIOSK, firstName, lastName, phone, email?}` → 201 with `temporaryPassword` (shown once). 409 `PHONE_ALREADY_EXISTS` / `EMAIL_ALREADY_EXISTS`. |
| GET | `/admin/staff` | ADMIN | D2 | Paginated; `?role=`, `?includeInactive=true`. |
| POST | `/admin/staff/:id/deactivate` | ADMIN | D2 | [R-43]; 409 `LAST_ACTIVE_ADMIN` [R-45]. |
| POST | `/admin/staff/:id/reactivate` | ADMIN | D2 | |

**Auth rules (D2):** every endpoint needs `Authorization: Bearer <accessToken>` unless marked
public. While `mustChangePassword` is true, every endpoint except change-password, logout and
`/me` returns `403 PASSWORD_CHANGE_REQUIRED`. Wrong role → `403 FORBIDDEN`.
