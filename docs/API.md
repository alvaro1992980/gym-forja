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
