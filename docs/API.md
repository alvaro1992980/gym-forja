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

| GET | `/admin/members/preview` | ADMIN | D3 | `?tier&months&startDate?` → `{periodStart, periodEnd, suggestedAmount, currency, tierApplies}` for a new member. |
| POST | `/admin/members` | ADMIN | D3 | User + membership + NEW payment (one transaction). Returns member detail + `temporaryPassword`. 400 `START_DATE_OUT_OF_RANGE`, `AMOUNT_NOTE_REQUIRED`; 409 phone/email. |
| GET | `/admin/members` | ADMIN | D3 | `q, tier, status=active\|expiring\|expired\|inactive, expiringWithinDays, trainerId, sort=name\|endDate\|createdAt`, paginated. |
| GET / PATCH | `/admin/members/:id` | ADMIN | D3 | Detail (profile incl. medical notes, membership, trainer, last 10 check-ins, payments). PATCH: profile fields only; `null` clears. |
| POST | `/admin/members/:id/deactivate` · `/reactivate` · `/reset-password` | ADMIN | D3 | [R-43] / [R-44]; reset returns `temporaryPassword`. |
| GET | `/admin/members/:id/payments/preview` | ADMIN | D3 | `?tier&months` → period [R-07]/[R-08], suggested amount [R-10], `tierApplies: unchanged\|now\|scheduled` [R-09]. |
| POST | `/admin/members/:id/payments` | ADMIN | D3 | `{tier, months, amount, method, note?, applyTierNow?}` → `{payment, membership}`. |
| POST | `/admin/members/:id/tier-change/preview` | ADMIN | D3 | `{toTier}` → `{fromTier, toTier, isUpgrade, daysLeft, suggestedAmount, currency, warning}`. |
| POST | `/admin/members/:id/tier-change` | ADMIN | D3 | `{toTier, amount?, method?, note?}` → `{membership, payment\|null}`. 409 `MEMBERSHIP_EXPIRED`; 400 `TIER_UNCHANGED`, `PAYMENT_METHOD_REQUIRED`, `DOWNGRADE_HAS_NO_CHARGE`. |
| POST | `/admin/payments/:id/void` | ADMIN | D3 | `{reason}` → `{payment, membership}` (dates recalculated). 409 `PAYMENT_ALREADY_VOIDED`. |
| GET | `/admin/payments` | ADMIN | D3 | `from, to, method, memberId, includeVoided`, paginated, plus `totals {count, amount, currency}` (non-voided). |
| GET / PUT | `/admin/pricing` | ADMIN | D3 | `[{tier, monthlyPrice, currency}]`; PUT `{prices: [{tier, monthlyPrice}]}` (1–3 tiers). |
| GET / PUT | `/admin/settings` | ADMIN | D3 | `{gymName, timezone (read-only), checkinCooldownMinutes, insideWindowMinutes, defaultCountryCode}`. |
| GET | `/me/membership` | MEMBER | D3 | `{tier, startDate, endDate, daysLeft, status, nextTier, nextTierStartDate, trainer}`. |
| GET | `/me/payments` | MEMBER | D3 | Own non-voided payments, no notes, paginated. |

| GET | `/kiosk/qr-token` | KIOSK | D6 | `{token, expiresAt, refreshInSeconds: 30, gymName}` (gym name since D7, for the kiosk screen). JWT signed with `QR_TOKEN_SECRET`, claims `{typ:"checkin", kid, jti, iat, exp}`, valid 45 s [R-18]. |
| POST | `/checkins` | MEMBER | D6 | `{qrToken}` → `200 {result: SUCCESS\|DUPLICATE, duplicate, checkinId, checkedInAt, member:{firstName}, membership:{tier, endDate, daysLeft}, todayWorkout: null}` [R-19]. 400 `QR_TOKEN_INVALID` / `QR_TOKEN_EXPIRED`; 403 `MEMBERSHIP_EXPIRED` (`details.endDate`) / `ACCOUNT_INACTIVE`. Every scan stores a `CheckinAttempt` [R-22]. 10/min per member. |
| GET | `/admin/checkins` | ADMIN | D6 | `from, to` (gym dates, inclusive), `memberId`, paginated. |
| GET | `/admin/checkins/inside` | ADMIN | D6 | `{count, windowMinutes, items}`: latest check-in of each member in the last `insideWindowMinutes` [R-23]. |
| GET | `/admin/checkins/attempts` | ADMIN | D6 | Denied and invalid attempts by default; `result=` for one result; `from, to, memberId`, paginated. |
| GET | `/me/checkins` | MEMBER | D6 | Own check-ins `{id, tier, createdAt}`, `from, to`, paginated. |

Money is sent as a JSON number (≤ 2 decimals) and returned as a string (`"150.00"`).

## Realtime (D6)

Socket.IO namespace **`/realtime`** on the API host (e.g. `http://10.0.2.2:3000/realtime`).

- Connect with the access token: `io(url + '/realtime', { auth: { token } })`. Invalid tokens,
  deactivated accounts and pending password changes get an `unauthorized` event and are
  disconnected.
- After authentication the server emits **`ready`** `{rooms}`. Only ADMIN sockets join `admins`.
- Events to `admins`:
  - **`checkin.created`** `{checkinId, member: {id, firstName, lastName}, tier, daysLeft, createdAt}`
    (not sent for duplicates [R-19]);
  - **`checkin.denied`** `{member: {id, firstName, lastName}, reason: EXPIRED|INACTIVE, endDate, createdAt}`.
- On reconnect, clients reload `GET /admin/checkins/inside` to fill any gap (section 8.5).

**Auth rules (D2):** every endpoint needs `Authorization: Bearer <accessToken>` unless marked
public. While `mustChangePassword` is true, every endpoint except change-password, logout and
`/me` returns `403 PASSWORD_CHANGE_REQUIRED`. Wrong role → `403 FORBIDDEN`.
