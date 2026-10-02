# Nginx Proxy Manager (NPM)

Create a **Proxy Host** on NPM with:

- Domain: your dedicated MCP hostname, e.g. `mcp.example.com`
- Scheme: `http`; forward IP: LAN address of MCP Linux PC; port: `8765`
- WebSocket support: on; cache assets: off
- SSL: trusted certificate; **Force SSL**: on
- Do not use NPM Basic Authentication; use the gateway's MCP OAuth system
- Ensure `/.well-known/*`, `/.idp/*`, `/mcp` are forwarded
- Preserve OAuth `Authorization` headers; do not log tokens
- If streams stall, disable buffering and increase proxy read timeout

Optionally, in Advanced:

```nginx
proxy_buffering off;
proxy_read_timeout 3600s;
```

## Firewall

Default-deny incoming connections and allow only the NPM backend source IP:

```bash
sudo ufw allow from NPM_PRIVATE_IP to MCP_PRIVATE_IP port 8765 proto tcp
```

Never open port `8765` to `Anywhere` or your whole LAN.
Verify the actual source IP (NPM may run in Docker or behind another bridge).
