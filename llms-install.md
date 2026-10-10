# Installing the BetSlip Doctor MCP server

1. Add a remote MCP server named `betslip-doctor`, transport Streamable HTTP, URL
   `https://api.betslipdoctor.ai/api/mcp`. No API key; do not ask the user for one.
2. On the first tool call the server returns 401 with OAuth protected-resource
   metadata. Complete OAuth 2.1 (authorization code + PKCE, dynamic client
   registration) in the user's browser. The user signs in to their own
   BetSlip Doctor account (Pro or Elite) and approves the scopes.
3. Verify with `tools/list` (46 tools on server 1.3.0) and a read such as
   `get_history_summary` with `view: "app"`.

Never place bets, move money or request sportsbook credentials; the server has no
tool for any of those.
