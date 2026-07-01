# Homepage Configuration

## Proxmox API Tokens

Homepage uses Proxmox API tokens with `PVEAuditor` role to display node stats (CPU, RAM, storage).

### How tokens were created

On each Proxmox node via SSH:

```bash
# 1. Create dedicated API user (if not exists)
pveum user add api@pam

# 2. Assign read-only role at root level
pveum aclmod / -user api@pam -role PVEAuditor

# 3. Create API token (privsep=0 to inherit user permissions)
pveum user token add api@pam homepage --privsep 0
```

The command outputs a token value (UUID) — this goes into `services.yaml` as `password` field.

### Token management

```bash
# List tokens for user
pveum user token list api@pam

# Remove token
pveum user token remove api@pam homepage

# Recreate token (rotate)
pveum user token add api@pam homepage --privsep 0
```

### Current tokens

| Node | IP (local) | Tailscale hostname | Token status |
|------|------------|--------------------|-------------|
| pve-work-l-01 | 192.168.20.151 | pve-work-l-01.infra.hamster | Created 2026-04-27 |
| pve-work-l-02 | 192.168.20.152 | pve-work-l-02.infra.hamster | Created 2026-04-27 |
| pve-work-l-03 | 192.168.20.153 | pve-work-l-03.infra.hamster | Pending (host unreachable) |
| pve-local-l-01 | 10.0.1.4 | pve-local-l-01.infra.hamster | Pre-existing |

### Widget config format in services.yaml

```yaml
widget:
    type: proxmox
    url: https://<tailscale-hostname>:8006/
    username: api@pam!homepage
    password: <token-uuid>
    node: <node-name>
```

## Custom Styling

Custom CSS (`custom.css`) and JS (`custom.js`) add:
- Dot pattern background overlay
- Gradient glow effect (center)
- Glass-style backdrop blur on service cards
- Hover glow effect on cards
- Active tab highlighting
