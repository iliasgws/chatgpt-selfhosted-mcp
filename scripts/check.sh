#!/usr/bin/env bash
set -euo pipefail
ENV="$HOME/.config/desktop-mcp-gateway/auth.env"
[[ -r "$ENV" ]] || { echo "Missing: $ENV" >&2; exit 1; }
# Do not enable shell tracing: this file includes a secret.
set -a
source "$ENV"
set +a
case "$EXTERNAL_URL" in
  https://*) : ;;
  *) echo "ERROR: EXTERNAL_URL must use https://" >&2; exit 1;;
esac
BASE="http://${LISTEN_ADDRESS}"
echo "Checking backend HTTP 401..."
code="$(curl --noproxy '*' -sS --max-time 8 -o /dev/null -w '%{http_code}' "$BASE/mcp")"
[[ "$code" == 401 ]] || { echo "Unexpected backend status: $code" >&2; exit 1; }
echo "Checking public HTTPS OAuth discovery..."
curl --noproxy '*' -fsS --max-time 12 \
  "$EXTERNAL_URL/.well-known/oauth-authorization-server" | \
  python3 -c 'import sys,json;x=json.load(sys.stdin);print("issuer:",x["issuer"])'
echo "Checking HTTP -> HTTPS redirect..."
curl --noproxy '*' -sS --max-time 10 -o /dev/null \
  -w 'HTTP status=%{http_code}, redirect=%{redirect_url}\n' \
  "http://${EXTERNAL_URL#https://}/mcp"
echo 'PASS: backend protected and OAuth discovery available. Test OAuth login separately.'
