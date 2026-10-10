# BetSlip Doctor MCP tools

Live list from `tools/list` on https://api.betslipdoctor.ai/api/mcp (server 1.3.0, 46 tools, read 2026-10-10). Every tool runs as the one signed-in BetSlip Doctor account. None places a bet.

| Tool | What it does | Read-only |
| --- | --- | --- |
| `get_tracked_slips` | Read the authenticated user's tracked ticket trees and tracking lifecycle. | yes |
| `track_slip` | Create or revise one of the authenticated user's ticket trees. | no |
| `get_todays_board` | Live sports board: upcoming and in-play games with main-market prices (moneyline, spread, total) and the best posted price per selection across connected books. | no |
| `grade_slip` | Use version bsd-agent-grade-v1 and a unique commandKey (16-120 characters) for every action. | no |
| `get_saved_reports` | For current Grade, send version bsd-agent-grade-v1 and action: list (optional limit 1-20 and cursor), job or report (jobId UUID required), or progress (jobId UUID required; optional after 0-1000000 and limit 1-100). | yes |
| `get_history_summary` | The authenticated user's imported betting-history ledger: W-L record, stake and net over lifetime/30d/7d windows, sync freshness, and their most recent bets. | yes |
| `price_shop_slip` | Compare posted prices across books for each leg of a slip (main markets). | no |
| `doctor_conversation` | The app Doctor conversation. | no |
| `tail_read` | Send version bsd-agent-tail-v1 and action feed (optional feed/profileId/listId/search/limit/cursor) or post (postId). | yes |
| `tail_post` | Send version bsd-agent-tail-v1. | no |
| `quote_grade` | Persist a Grade quote for an owned saved ticketId or exactly one confirmed manual ticket, with the requested depth and optional funding. | no |
| `start_grade` | Start the owned Grade quoteId after the customer has seen and accepted its allowance quote. | no |
| `cancel_grade` | Cancel an owned Grade jobId through the app service. | no |
| `list_grade_jobs` | Read the authenticated account’s current Grade library, with optional limit 1-20 and account-bound cursor. | yes |
| `get_grade_job` | Read the owned Grade jobId and its current durable status. | yes |
| `get_grade_progress` | Read saved progress for the owned Grade jobId, with optional after sequence and limit 1-100. | yes |
| `get_grade_report` | Return the verified immutable saved report for an owned completed Grade jobId. | yes |
| `open_doctor_conversation` | Persist an app Doctor thread, optionally attached to an owned ticket, report or history item. | no |
| `list_doctor_conversations` | Read this account’s saved app Doctor threads. | yes |
| `get_doctor_conversation` | Read the owned threadId, saved user messages, Doctor answers and jobs; optional before pages older messages. | yes |
| `get_doctor_quota` | Read this account’s current app consult allowance, held and used amounts, and reset information. | yes |
| `get_doctor_memory` | Read this authenticated account’s confirmed notes, active status, current revisions and memory generation. | yes |
| `remember_doctor_note` | Save only a preference, goal, constraint or context note the customer explicitly asked Doctor to remember. | no |
| `forget_doctor_note` | Remove the exact owned note only after the customer explicitly asks to forget it. | no |
| `quote_doctor_reply` | Persist an app consult quote for text in the owned threadId at its current sequence, with optional responseStyle learning/technical/roast for this reply. | no |
| `start_doctor_reply` | Start the owned consult quoteId after the customer has seen and accepted the quote. | no |
| `get_doctor_job` | Read the owned Doctor jobId, including its real saved answer when available. | yes |
| `get_doctor_events` | Read saved events for the owned Doctor jobId, optionally after a sequence. | yes |
| `cancel_doctor_reply` | Cancel an owned Doctor jobId under the app cancellation and reservation rules. | no |
| `get_tail_feed` | Read the app Tail feed with its account-filtered community, following, own, profile, bookmark or private-list visibility. | yes |
| `get_tail_post` | Read one app Tail postId visible to this account under the same moderation and privacy rules. | yes |
| `preview_tail_post` | Compute the exact app sharing preview and binding from an owned saved Grade report or Doctor exchange draft. | yes |
| `publish_tail_post` | Submit the exact customer-approved draft and previewBinding to the app moderation queue. | no |
| `create_tracked_slip` | Create an owned ticket tree in building state with a stable client_mutation_id for retries. | no |
| `revise_tracked_slip` | Overwrite the owned tracked ticket_id with the supplied ticket tree in building state. | no |
| `show_saved_grade` | Return the verified immutable saved report for an owned completed Grade jobId. | yes |
| `show_doctor_conversation` | Read the owned threadId, saved user messages, Doctor answers and jobs; optional before pages older messages. | yes |
| `show_tail_feed` | Read the app Tail feed with its account-filtered community, following, own, profile, bookmark or private-list visibility. | yes |
| `show_tail_post` | Read one app Tail postId visible to this account under the same moderation and privacy rules. | yes |
| `show_betting_history` | Show the connected account’s recorded profit/loss chart and actual win/loss counts. | yes |
| `show_history_records` | Show a bounded page of owned History records and their saved Grade association. | yes |
| `export_betting_history` | Read one real CSV export page for the owned History filters. | yes |
| `show_saved_slip` | Show an owned saved ticket with its exact single-book saved picks, odds and stake. | yes |
| `prepare_sportsbook_handoff` | Prepare the existing app’s fresh, vetted direct sportsbook link for an owned saved ticket. | yes |
| `preview_tail_slip` | Show current supported prices for tailing or fading one visible public post at the customer’s chosen bookId and jurisdiction. | yes |
| `copy_tail_slip` | After the customer reviews every current leg and confirms the exact stake/currency/settlement fields, save the app’s owned Tail/Fade ticket using the preview binding and CONFIRM_COPY_TICKET. | no |
