#!/usr/bin/env bash
set -euo pipefail
umask 077
# Installs binaries and a template. No ports are opened or services started.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION=v2.10.2
SHA256=1c76b230fdb6c536a0912c059232cba2229acbcf1f02a11a5d0664781326bcd6
for dep in curl sha256sum install node desktop-commander openssl python3; do
  command -v "$dep" >/dev/null || { echo "Missing: $dep" >&2; exit 1; }
done
mkdir -p "$HOME/.local/bin" "$HOME/.config/desktop-mcp-gateway" \
  "$HOME/.local/state/desktop-mcp-gateway" "$HOME/.config/systemd/user"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
curl -fL --retry 2 --max-time 45 -o "$TMP" \
 "https://github.com/sigbit/mcp-auth-proxy/releases/download/${VERSION}/mcp-auth-proxy-linux-amd64"
printf '%s  %s\n' "$SHA256" "$TMP" | sha256sum -c -
install -m 700 "$TMP" "$HOME/.local/bin/mcp-auth-proxy"
NODE="$(command -v node)"
DC="$(readlink -f "$(command -v desktop-commander)")"
printf '#!/bin/sh\nexec "%s" "%s"\n' "$NODE" "$DC" > "$HOME/.local/bin/start-dc-mcp"
chmod 700 "$HOME/.local/bin/start-dc-mcp"
ENV="$HOME/.config/desktop-mcp-gateway/auth.env"
if [[ ! -e "$ENV" ]]; then
  cp "$ROOT/config/auth.env.example" "$ENV"
  python3 - "$ENV" <<'PYSECRET'
from pathlib import Path
from subprocess import check_output
import sys
path=Path(sys.argv[1])
text=path.read_text()
text=text.replace('REPLACE_WITH_LOCALLY_GENERATED_SECRET', check_output(['openssl','rand','-hex','32'],text=True).strip())
path.write_text(text)
PYSECRET
  echo "Created private auth.env: edit external domain and private IP addresses."
else
  echo "Existing private auth.env preserved."
fi
chmod 600 "$ENV"
UNIT="$HOME/.config/systemd/user/desktop-mcp-selfhosted.service"
if [[ ! -e "$UNIT" ]]; then
  install -m 600 "$ROOT/systemd/desktop-mcp-selfhosted.service" "$UNIT"
else
  echo "Existing live systemd unit preserved. Review template manually."
fi
systemctl --user daemon-reload
echo "Review the firewall and TLS/OAuth settings before enabling the service."
