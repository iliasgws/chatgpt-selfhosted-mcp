# ChatGPT Self-Hosted Linux MCP Gateway

A reproducible **self-hosted** bridge between ChatGPT Web and an existing local
[Desktop Commander MCP](https://github.com/wonderwhy-er/DesktopCommanderMCP) server using
[MCP Auth Proxy](https://github.com/sigbit/mcp-auth-proxy) and Nginx Proxy Manager (NPM).
No Desktop Commander hosted cloud relay or hosted call quota is required.

This repository contains **deployment scripts, service templates and documentation**, **not**
the upstream Desktop Commander or MCP Auth Proxy source code. Upstream licenses remain applicable.

## Architecture

```text
ChatGPT Web
     ↓ HTTPS + OAuth
Your public domain → Nginx Proxy Manager (TLS termination)
     ↓ host firewall: NPM source IP only
Linux: mcp-auth-proxy (OAuth 2.1 / Streamable HTTP)
     ↓ stdio subprocess
Linux: Desktop Commander MCP (shell, files, processes)
```

## Requirements

- Linux with systemd user services; Node.js 18+ and a working `desktop-commander` executable
- NPM with HTTPS certificate and a domain you control
- `curl`, `sha256sum`, `openssl`, `python3`, `git`
- UFW/nftables with default-deny inbound policy
- ChatGPT account that actually permits the MCP actions you need

## Deploy

1. Install the [local Desktop Commander server](https://github.com/wonderwhy-er/DesktopCommanderMCP).
2. Review, then run `bash scripts/install.sh` (pins and SHA-256-verifies OAuth gateway v2.10.2).
3. Edit the **private**, generated `~/.config/desktop-mcp-gateway/auth.env`:
   - `PASSWORD` is generated randomly; do not print/share/commit it.
   - `EXTERNAL_URL` is `https://YOUR_DOMAIN`.
   - `LISTEN_ADDRESS` is `YOUR_LINUX_LAN_IP:8765`.
   - `TRUSTED_PROXY_IP` is the actual NPM source address.
4. Inspect the systemd unit and enable it:
   `systemctl --user enable --now desktop-mcp-selfhosted.service`.
5. Apply a restrictive NPM-only firewall rule. See [NPM guide](docs/nginx-proxy-manager.md).
6. Configure NPM hostname, certificate and Force SSL.
7. Verify security with `bash scripts/check.sh`.
8. In ChatGPT, connect an OAuth-enabled MCP client to `https://YOUR_DOMAIN/mcp`.
9. Complete the OAuth login, then test harmless read-only tools first.

## Already installed?

The installation script **preserves existing** private credentials and existing
systemd unit rather than overwriting your working service. If changing the
service, review the template and migrate manually.

## Security

Read [security guidance](docs/security.md). This gateway can execute shell commands
as the service account. Use least privilege and treat it as a sensitive internet-facing service.
The repository intentionally contains only placeholder hostnames/IP addresses and **no secrets**.

## Source and licensing

Original deployment files are MIT-licensed. Desktop Commander MCP and
MCP Auth Proxy are separate projects with their own licenses and release practices.
