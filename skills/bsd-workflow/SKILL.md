---
name: bsd-workflow
description: Use the selected BetSlip Doctor customer plugin for sports research, saved Grades, Doctor conversations, Live games, slips, history and Tail. Also use when its customer connection is missing or expired; stop at that connection boundary instead of substituting a QA or other BSD connection.
---

# BetSlip Doctor customer workflow

Use the tools exposed by this plugin's `bsd` MCP server, whose endpoint is
`https://api.betslipdoctor.ai/api/mcp`. Respect the account, permissions and
entitlements attached to that connection.

## Keep the selected connection

Discover only this selected customer plugin's tools. A tool with a matching
name in a different plugin is not the same connection. Never substitute
another plugin, another user's connection, or a local database or terminal
request for this customer plugin.

If this plugin's tools are unavailable, or its tool returns an authentication
or entitlement error, stop this request and explain that precise limitation.
Ask the user to connect the selected BetSlip Doctor customer plugin through
the host's normal connection settings. Do not reconnect a different plugin,
invent a permission link, expand scopes, change a plan, or assume two
connections authenticate the same account. Do not claim a saved report was
read when no report was returned. No report-specific score or findings can be
recovered from memory or another chat.

## Read saved information

Prefer the following fixed read operations when this plugin exposes them:

- Latest saved Grade: start with `list_grade_jobs` with limit 5. Select the
  newest returned `page.items` entry with a non-null report and call
  `get_grade_report` with its owned job `id`. If this page has no report,
  follow the returned opaque `page.next` cursor through subsequent pages until
  a report is found or the library is exhausted. Do not invent cursors or
  treat queued/failed jobs as saved reports. Claim no saved report exists only
  after exhausting the library; if inspection stops early, state that none was
  found in the pages inspected.
- Saved Doctor reply: `list_doctor_conversations`, then
  `get_doctor_conversation` with returned owned thread IDs. If the user asks
  specifically for the newest conversation and it is empty, say that it has
  no saved reply; do not silently substitute an older thread. If the request
  is for the newest conversation containing a saved Doctor reply, inspect
  the returned conversations in recency order until a saved reply is found
  or the returned list is exhausted. Identify the actual thread and preserve
  any inspection limit. An unfinished consult is not a saved answer.
- Live board: `get_todays_board` with `view: app`, the requested category and
  limit. Preserve the returned event status, freshness and price limitations.
- Saved slips: `get_tracked_slips` with `view: app` and the requested limit.
- Betting history: `get_history_summary` with `view: app`, the requested
  range and record kind. Do not send `recent` with `view: app`; `recent` is
  legacy-only. Preserve the records included in the returned totals and report
  empty groups honestly without inventing totals or records.

Fixed operations do not accept client-supplied `action` or `version` fields.
Use identifiers from actual returned records, not guesses. Reading saved
information must not quote, start or spend a new Grade or Doctor allowance.
If a client exposes only the legacy operations, use their published schema
only through this same customer server; never switch connections to find them.

## Research and publishing

### Share a saved Grade on Tail

Tail is BSD's community for sharing and discussing AI-graded bets. Keep the
user in the same agent chat for reading, previewing and confirming a post.

1. For community browsing use `get_tail_feed` and, when needed,
   `get_tail_post` with IDs from actual returned posts. Distinguish a graded
   ticket from a Doctor exchange. Preserve moderation and source limitations.
2. For sharing a graded bet, first retrieve the user's actual saved Grade using
   the library/report flow above. Its owned Grade **job ID** is the
   `reportId` required by the Tail draft; a ticket ID, digest or invented score
   is not a replacement. New research is a separate requested quote/start flow.
3. Call `preview_tail_post` with the chosen caption, stake visibility and
   truthful placement. Use `asking` when the user has not said the bet was
   placed. Show the real public preview before asking for publication.
   A missing admitted social profile, scope or usable saved Grade is a blocker;
   do not silently create a profile or widen access.
4. Explain the actual saved Grade, including a null letter or partial research.
   The public ticket is tied to the original author and saved prices;
   `currentPrice: false` is not a current quote. Its public shape contains only
   part of the private report. Do not invent evidence percentages, confidence,
   source counts or source citations absent from the returned public preview.
5. Only after explicit permission to publish that exact preview, call
   `publish_tail_post` with the unchanged draft and returned preview binding,
   `PUBLISH_POST`, a stable command key, truthful placement confirmation and
   the required F warning acknowledgement. Never choose `dont_ask_again` unless
   the user requested that preference. Changes require a new preview.
6. Report the actual receipt. `pending` means awaiting moderation, not public
   visibility. Reuse the same command key for retrying the exact same command;
   never create duplicate posts merely because a response was delayed.

Do not publish after a read-only or preview-only request. Reading or tailing a
shared ticket never authorizes sportsbook placement. These tools do not expose
every social interaction in the app; do not promise likes, replies, follows or
copying unless the selected server actually exposes a matching operation.

Use the connected server's published quote/start workflow only when the user
requests new research. Use `price_shop_slip` for requested posted-price
comparison and the published tracking operations only for requested saved-slip
creation or revision; neither operation places a wager. Preserve
quoted allowance, consent, command keys,
confirmation and existing account limits. Follow the published Tail preview,
confirmation and moderation flow only when the user requests posting. A request
to read must not become new research, tracking or publishing.

Explain the actual returned score and its meaning. Historical evidence support
is not a calibrated win probability. Keep citations, missing facts, freshness,
sample sizes and confidence limitations visible. Do not invent a numerical
Grade, improve a score, or turn unavailable data into an affirmative answer.

## Cards and the sportsbook link

When the host renders MCP Apps (ChatGPT), prefer the card tools for showing
saved records: `show_saved_grade` (owned Grade job ID), `show_doctor_conversation`,
`show_tail_feed`, `show_tail_post`, `show_betting_history`, `show_history_records`,
`export_betting_history` and `show_saved_slip`. They read the same saved data as
the fixed read operations and never start paid work.

`prepare_sportsbook_handoff` prepares a vetted link for an owned saved ticket's
own sportsbook only when the user asks for it. The link opens only on the user's
tap; the user reviews, confirms and pays inside the sportsbook. Never describe it
as placing, submitting or recording a bet. `preview_tail_slip` shows current
prices for tailing or fading a visible post; `copy_tail_slip` saves an unplaced
owned ticket only after the user reviews every leg and confirms the exact fields.

BSD does not place wagers, fund sportsbooks, move money, buy credits, change
billing, obtain sportsbook credentials, or expose another person's private
history or Doctor messages. Explain those limits without invoking a tool for an
unsupported request.
