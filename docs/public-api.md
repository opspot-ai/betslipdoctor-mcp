# BetSlip Doctor public Agent API

Base URL: `https://api.betslipdoctor.ai`

The machine-readable OpenAPI 3.1 contract is published at `/openapi.json`.
Every account-data endpoint requires an OAuth access token and the named scope.
Access tokens are audience-bound to `/api/mcp`; that audience represents both
the MCP and `/api/v1` resource surfaces.

| Method | Path | Scope | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/v1/slips` | `slips.read` | Read tracked ticket trees |
| `POST` | `/api/v1/slips` | `slips.track` | Create/revise a tracked ticket |
| `POST` | `/api/v1/grade` | `slips.grade` | Quote/start/cancel a current Grade job |
| `GET` | `/api/v1/history` | `history.read` | Read imported betting-history summary |
| `GET` | `/api/v1/reports` | `reports.read` | Read Grade jobs, progress, reports and library |
| `GET` | `/api/v1/board` | `odds.read` | Read the main-market board |
| `POST` | `/api/v1/price-shop` | `odds.read` | Compare posted prices per leg |

Successful responses are the tool-specific JSON object described by OpenAPI.
Request errors use `{ "error": { "code", "message" } }`. OAuth failures use
the OAuth `{ "error", "error_description" }` shape and may include a
`WWW-Authenticate` discovery challenge.

## Track request

`POST /api/v1/slips` requires:

- `client_mutation_id`: a caller-generated retry-stable idempotency key;
- `ticket`: the current two-level `BetTicketContract`;
- `ticket_id` plus `expected_revision` when revising a server ticket;
- captured sportsbook status stays inside the ticket unchanged. Third-party
  clients cannot self-certify the server's account-graph settlement lifecycle.

Stale revisions fail with `409`; the server copy wins. Reads project only the
safe ticket contract or legacy pick/market/odds fields. Provider placement ids,
deep links, and arbitrary extra input keys are stripped before echo.

## Durable Grade

The HTTP routes use the same versioned tool service described in the
[Grade connector contract](https://api.betslipdoctor.ai/docs/mcp-connect.md#current-grade-contract).
A canonical BSD account with an authoritative Pro or Elite entitlement is required.
The adapter does not grant AI consent or change plan, unit, cost, model or depth limits.

`POST /api/v1/grade` accepts `version: "bsd-agent-grade-v1"` with:

| Action | Required fields | Response |
| --- | --- | --- |
| `quote` | `commandKey`, `depth`, either `ticketId` or confirmed manual `ticket`; optional `funding` | `{version,action,ticketId,quote}` |
| `start` | `commandKey`, `quoteId` | `{version,action,job}` |
| `cancel` | `commandKey`, `jobId` | `{version,action,job}` |

Show the quote's funding maximum, explanation and expiry before accepting it.
Use a retry-stable 16–120 character `commandKey` containing letters, digits,
underscores or hyphens. Access-token refresh does not change idempotency. A
changed request with the same key conflicts. Quote expiry needs a new quote/key.
The full manual-ticket schema is in OpenAPI; supplied values must be confirmed,
not invented. Existing provider tickets must come through BSD's verified intake.
Text and legacy SGP Grade inputs return `400 migration_required`, without grading.

`GET /api/v1/reports` uses query parameters `version=bsd-agent-grade-v1` and:

| Action | Additional parameters | Response |
| --- | --- | --- |
| `list` | `limit` (1–20, default 10), optional `cursor` | `{version,action,page}` |
| `job` | `jobId` | `{version,action,job}` |
| `progress` | `jobId`, `after` (0–1000000, default 0), `limit` (1–100, default 100) | `{version,action,page}` |
| `report` | `jobId` | `{version,action,report}` |

Unknown, duplicate or action-inappropriate parameters are rejected. Progress
returns the existing `bsd-grade-progress-v1` page unchanged: drain `hasMore`
pages using `nextAfter` before reconciling the snapshot. No read starts research.
Live progress can be unavailable when disabled; legacy jobs have no invented
hierarchy. Only a readable verified report proves report readiness.
Unversioned `report_id`/`limit` reads remain legacy-report reads only.

HTTP errors preserve canonical status codes, including `402` allowance/depth/cost
refusals, `403` consent/entitlement, `404` missing/private resources or unavailable
reports, `409` idempotency/expired quote, `429` throttling and `503` retryable
capacity/service failures. `retryable` and optional `retryAfterSeconds` accompany
the error; `Retry-After` is preserved when available. Inspect the saved job after a
timeout or disconnect instead of creating a second start operation.

## Non-goals

This API cannot place or prepare a wager, expose sportsbook credentials, change
billing, or change privacy settings. It is decision support for entertainment,
not financial advice or a guarantee.
