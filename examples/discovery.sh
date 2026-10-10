#!/bin/sh
# List the BetSlip Doctor MCP tools without signing in (discovery is public; every tool call needs OAuth).
URL=https://api.betslipdoctor.ai/api/mcp
H='-H content-type:application/json -H accept:application/json,text/event-stream'
curl -s -X POST $URL $H -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"discovery","version":"0"}}}'
echo
curl -s -X POST $URL $H -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
echo
