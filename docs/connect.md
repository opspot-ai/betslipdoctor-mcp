# Connect an agent to BetSlip Doctor

BetSlip Doctor exposes a remote MCP server at:

```text
https://api.betslipdoctor.ai/api/mcp
```

It supports the MCP Streamable HTTP transport with stateless JSON responses. An
unauthenticated client can initialize, ping, and list tools. Every tool call uses
OAuth 2.1 authorization code + PKCE and runs as exactly one BetSlip Doctor user.
Copied web/iOS session tokens are intentionally rejected.

Agent Connect requires a canonical BSD account with a Pro or Elite product entitlement.
Authorization and every call use the same subscription resolver as current Grade,
including its existing grace and revocation policy. Legacy session tier claims or
subscription mirrors do not grant access. Revoking a grant or replaying an old
refresh token suspends the connection on its next request. Free and Starter do not qualify.

## OAuth discovery

Clients should begin with protected-resource discovery:

```text
https://api.betslipdoctor.ai/.well-known/oauth-protected-resource
```

Authorization-server metadata is published at:

```text
https://api.betslipdoctor.ai/.well-known/oauth-authorization-server
```

The server supports dynamic client registration, exact redirect URI matching,
PKCE S256, 15-minute opaque audience-bound access tokens, rotating refresh
tokens, and owner-managed grant revocation. Raw codes and tokens are never
stored; only SHA-256 hashes and short display prefixes enter Postgres.

Scopes:

| Scope | Access |
| --- | --- |
| `slips.read` | Read the user's tracked ticket trees |
| `slips.grade` | Quote, start and cancel current Grade jobs for confirmed tickets |
| `slips.track` | Create or revise tracked ticket truth |
| `history.read` | Read the user's imported betting-history summary |
| `reports.read` | Read the user's Grade jobs, progress, library and saved reports |
| `odds.read` | Read the board and compare posted prices |
| `doctor.use` | Read Doctor conversations and request consults under the app's consent, plan and allowance rules |
| `tail.read` | Read Tail posts and feeds visible to the connected account |
| `tail.post` | Preview and publish from that account through the app's review flow |

The same scoped grant works against the public HTTP API described by
[`openapi.json`](https://api.betslipdoctor.ai/openapi.json) and
[`public-api.md`](https://api.betslipdoctor.ai/docs/public-api.md).

## MCP tools

| Tool | Scope | What it does |
| --- | --- | --- |
| `get_tracked_slips` | `slips.read` | Reads safe tracked-ticket projections; no provider placement ids or deep links |
| `track_slip` | `slips.track` | Creates or revises a two-level ticket tree using a caller idempotency key |
| `grade_slip` | `slips.grade` | Quotes/starts/cancels the same durable Grade services and allowance as the app |
| `get_saved_reports` | `reports.read` | Reads owner-scoped Grade jobs, paginated progress, saved reports and library |
| `get_history_summary` | `history.read` | Reads W-L, stake/net, freshness, and recent imported bets |
| `get_todays_board` | `odds.read` | Reads main-market prices; metered as an odds refresh |
| `price_shop_slip` | `odds.read` | Compares posted prices per leg; metered as an odds refresh |
| `doctor_conversation` | `doctor.use` | Opens/reads threads, quotes/starts a consult, and reads its durable answer |
| `tail_read` | `tail.read` | Reads the same account-filtered Tail feed and posts as the app |
| `tail_post` | `tail.post` | Previews and publishes an owned saved Grade result or Doctor exchange for review |

The original seven tools remain. `get_tracked_slips`, `get_history_summary`, and
`get_todays_board` retain their existing response when `view` is omitted. Send
`view: "app"` to use the current app's saved-ticket library, History summary, or
Live games board. App view returns `{view: "app", data: <the app response>}`.
The Live games board identifies events and explicitly marks prices as not quoted;
it does not invent a current price. `price_shop_slip` remains the separate
main-market comparison tool. The app view uses the same owner, filters, cursors,
provider selection and rate rules as the app. Tracked ticket trees and canonical
saved Grade tickets are different app records; one ID is never silently treated
as the other.

### ChatGPT interactive cards (server 1.3.0)

Since server 1.3.0 the catalog has 46 tools. ChatGPT renders these as BetSlip
Doctor cards from the MCP Apps resource `ui://bsd/customer-cards-v2.html`
(`resources/list`, `resources/read`); other clients receive the same structured
JSON.

| Tool | Scope | What it shows |
| --- | --- | --- |
| `show_saved_grade` | `reports.read` | A saved Grade: score, letter, factors, picks and saved odds |
| `show_doctor_conversation` | `doctor.use` | The original saved Doctor exchange and its bound Grade |
| `show_tail_feed`, `show_tail_post` | `tail.read` | Tail posts with their saved Grade badges |
| `show_betting_history`, `show_history_records`, `export_betting_history` | `history.read` | Recorded profit/loss chart, records and one CSV page |
| `show_saved_slip` | `slips.read` | An owned saved ticket |
| `prepare_sportsbook_handoff` | `slips.read` + `odds.read` | A vetted link for the saved ticket's own sportsbook; opens only on the user's click |
| `preview_tail_slip` | `tail.read` + `odds.read` | Current prices for tailing or fading a visible post |
| `copy_tail_slip` | `tail.read` + `slips.track` + `odds.read` | After explicit review, saves an unplaced owned ticket |

None of these places a wager, starts a paid Grade or Doctor consult, or records a bet as placed.

## Doctor in the agent chat

Use `doctor_conversation` with `version: "bsd-agent-doctor-v1"`. The actions are:
`open` (optional owned ticket/report/History subject), `threads`, `conversation`,
`quota`, `quote`, `start`, `job`, `events`, and `cancel`. Writes require a
16–120-character `commandKey` that stays unchanged on retry. A normal message
follows `open` → `quote` with the thread's current `sequence` and the customer's
`text` → show the returned funding and expiry → `start` with `quoteId` → poll
`job`/`events`. A succeeded job contains the saved `bsd-doctor-answer-v1`; the
same answer is stored in `conversation`. The agent should give that answer in
its original chat after the saved result is readable. The request does not run
the Doctor model inside the MCP HTTP call. The app's AI consent, tier, consult
allowance, cost cap, queue, grounding and saved-message checks apply unchanged.

## Tail in the agent chat

`tail_read` with `version: "bsd-agent-tail-v1"` reads `feed` or one `post`.
`tail_post` uses `preview` with an owned saved Grade report draft or saved
Doctor exchange draft. Show the exact preview to the customer. `publish` requires
the same draft and returned `previewBinding`, a stable `commandKey`,
`confirmation: "PUBLISH_POST"`, `placementConfirmation`, and `fWarning` from the
app contract. It returns a pending review receipt, not immediate public
publication. The app's profile, source ownership, moderation, consent and
idempotency rules apply. The agent cannot place a sportsbook bet.

## Current Grade contract

Send `version: "bsd-agent-grade-v1"` on every current Grade action. `grade_slip`
accepts these exact alternatives:

- `quote`: `commandKey`, `depth` (`fast`, `smart`, `deep`, `elite`), optional
  `funding` (`auto`, `weekly`, `bug_bounty`), and either an existing canonical
  `ticketId` or an exact confirmed manual product `ticket`.
- `start`: `commandKey` and the returned `quoteId`.
- `cancel`: `commandKey` and `jobId`.

A manual ticket uses integer minor currency units, explicit event/selection fields,
settlement terms and `confirmation: "exact_fields_confirmed"`; its `source` and
selection `provider` must be `manual`. See the complete `GradeSlipRequest` schema
in [OpenAPI](https://api.betslipdoctor.ai/openapi.json). Provider tickets must
already exist through BSD's verified intake. The tracked two-level ticket tree
belongs to a separate storage contract; its ID is not a canonical Grade ticket ID.
Never flatten an SGP or invent missing fields. Prior `slipText`/`BetTicketContract`
Grade inputs return `migration_required`; they never invoke the older scorer.

The quote response is `{version, action: "quote", ticketId, quote}`. Show its
funding maximum, explanation and expiry before accepting it with `start`.
Starting returns `{version, action: "start", job}` and reserves the disclosed
allowance; it does not mean research is finished. Cancellation returns the saved
job with `action: "cancel"`. AI sharing consent must already be set in BSD; the
agent cannot grant consent or bypass the plan, unit, cost or queue gates.

`commandKey` is a caller-generated 16–120 character string using letters, digits,
underscores or hyphens. Keep it unchanged for retries of the same action. Reuse
with changed input returns `idempotency_conflict`; refresh or reconnect does not
create another ticket, job or allowance hold. Use a new key for a new quote after
expiry. A quote authorizes at most one job even with a different start key.

With `reports.read`, call `get_saved_reports` with the same version and:

- `{action: "list", limit?, cursor?}` → `{version, action, page}` (max 20).
- `{action: "job", jobId}` → `{version, action, job}`.
- `{action: "progress", jobId, after?, limit?}` → `{version, action, page}`
  containing the exact `bsd-grade-progress-v1` page (max 100).
- `{action: "report", jobId}` → `{version, action, report}` containing the same
  immutable, verified report available in BSD.

Progress starts at `after: 0`. Follow `nextAfter` while `hasMore` is true and
reconcile against the snapshot watermark; save the cursor for reconnect. Topic,
head, lead and writer transitions reflect durable engine events. A legacy job
can have an empty progress state. If live progress is disabled, use `job` status.
A terminal status or 100 settled topics is not a readable report: use the report
read or `snapshot.complete`. A pending report returns `report_unavailable`.

Unversioned `get_saved_reports` requests with `report_id`/`limit` retain access
only to legacy saved reports; they do not list current Grade jobs. Failures carry
stable codes and retryability; obey `retryAfterSeconds`/HTTP `Retry-After` where
present. Do not restart a job because a poll or transport request failed.

## Hard boundary

There is no wager-placement, wager-preparation, credential, billing, or privacy
tool. Outputs omit sportsbook deep links and placement identifiers. Screenshot
OCR and manual entry are the primary DraftKings ingest paths; BetSlip Doctor
does not scrape a logged-in My Bets tab.

## Connector setup

OAuth-capable MCP clients, including ChatGPT custom MCP servers and claude.ai
custom connectors, should be given only the MCP URL. They discover and run the
authorization flow automatically. The illustrated walkthrough for Claude,
ChatGPT, Claude Code and Codex is at https://betslipdoctor.ai/agents.

- **Claude (web, desktop, Cowork):** Customize → Connectors → + Add → Add
  custom connector → name it BetSlip Doctor → paste the URL → Continue. Under
  **Authentication** keep *Sign in now*; under **OAuth client** choose
  **Register automatically**. BetSlip Doctor registers clients dynamically and
  does not accept client-ID metadata documents, so *Use Claude's published
  identity* is refused with `invalid_client`. Enable the connector per chat
  from + → Connectors. On Team or Enterprise plans an Owner adds it under
  Organization settings → Connectors and members choose Connect. Vendor guide:
  https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp
- **Claude Code:** `claude mcp add --transport http betslip-doctor https://api.betslipdoctor.ai/api/mcp`,
  then `/mcp` (or `claude mcp login betslip-doctor`) to sign in. Vendor guide:
  https://code.claude.com/docs/en/mcp
- **ChatGPT (your own account):** https://chatgpt.com/plugins → + → Add custom
  MCP server → name → Connection: *Public endpoint* with the URL → configure
  authentication → *I understand and want to continue* → *Create as a plugin*
  → review the discovered tools → install. In a new conversation type `@` and
  pick BetSlip Doctor; after a server change open the connection and choose
  *Refresh*. Account and workspace policies decide whether custom MCP servers
  are allowed. Vendor guide:
  https://developers.openai.com/plugins/deploy/connect-chatgpt
- **Codex:** `codex mcp add betslip-doctor --url https://api.betslipdoctor.ai/api/mcp`,
  then `codex mcp login betslip-doctor`.

Agent Connect requires an active Pro or Elite BetSlip Doctor plan; the consent
page refuses Free and Starter accounts before any grant is created.

For clients that require manual OAuth wiring, register a client:

```bash
curl https://api.betslipdoctor.ai/api/oauth/register \
  -H 'content-type: application/json' \
  -d '{"client_name":"My Agent","redirect_uris":["http://localhost:4312/callback"]}'
```

Then send the user to `/api/oauth/authorize` with `response_type=code`, the
registered `client_id` and exact `redirect_uri`, an S256 `code_challenge`, the
requested scopes, and this exact resource audience:

```text
https://api.betslipdoctor.ai/api/mcp
```

Exchange the returned code at `/api/oauth/token` with the PKCE verifier. Refresh
requests must repeat `client_id` and `resource`. Clients must replace the old
refresh token atomically; replay revokes the whole grant family.

## Discovery smoke test

```bash
curl -s https://api.betslipdoctor.ai/api/mcp \
  -X POST \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"curl","version":"1"}}}'

curl -s https://api.betslipdoctor.ai/api/mcp \
  -X POST \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
```

An unauthenticated `tools/call` answers `401` with a `WWW-Authenticate` header
pointing back to protected-resource metadata.
