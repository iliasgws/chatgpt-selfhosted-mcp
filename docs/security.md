# Security considerations

This integration provides access to a real user's shell and filesystem. The MCP tool host is **not a sandbox**.

- Do **not** commit `~/.config/desktop-mcp-gateway/auth.env` or gateway state, tokens, cookies, device identity, SSH files, or journald logs.
- Restrict the inbound port to the NPM source IP (not the LAN or public internet).
- Require HTTPS and OAuth; verify missing or invalid bearer tokens get `401`.
- Use strong, randomly generated credentials and rate-limiting. Rotate credentials periodically.
- Prefer a dedicated minimally privileged Unix account and limit filesystem access.
- Avoid letting untrusted webpages or documents instruct an agent with terminal access (prompt injection).
- Pin and verify downloaded software; patch vulnerabilities in dependencies.
- Do not disable TLS certificate verification or forward secrets into logs.
- Before exposing publicly, test login, redirects, metadata and unauthorized POST/GET responses.

To stop a running deployment safely:

```bash
systemctl --user stop desktop-mcp-selfhosted.service
```

Live runtime files are **outside this repository** in `~/.config`, `~/.local/bin` and `~/.local/state`.
