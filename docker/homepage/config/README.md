# Homepage Configuration

## Proxmox API Tokens

Homepage reads node stats (CPU, RAM, storage) through a Proxmox API token holding the
read-only `PVEAuditor` role.

### Tokens are not stored here

`services.yaml` references them as `{{HOMEPAGE_VAR_*}}` placeholders. The values live
encrypted in `../secrets.sops.yaml` and are injected at startup:

```bash
cd docker/homepage
sops exec-env secrets.sops.yaml 'docker compose up -d'
```

Starting the stack without them fails immediately — the compose file marks each variable
required, so a dashboard never comes up with silently broken widgets.

### How the tokens were created

On each Proxmox node, over SSH:

```bash
pveum user add api@pve                              # if it does not exist
pveum aclmod / -user api@pve -role PVEAuditor       # read-only, whole tree
pveum user token add api@pve homepage --privsep 0   # inherit the user's permissions
```

### Managing them

```bash
pveum user token list api@pve
pveum user token remove api@pve homepage
pveum user token add api@pve homepage --privsep 0   # rotate
```

After rotating, re-encrypt the new value:

```bash
sops docker/homepage/secrets.sops.yaml
```

### Current mapping

| Node | Widget URL | Variable |
|---|---|---|
| pve-kvt-l-01 | https://192.168.20.151:8006/ | `HOMEPAGE_VAR_PVE_KVT_TOKEN` |
| pve-kvt-l-02 | https://192.168.20.152:8006/ | `HOMEPAGE_VAR_PVE_KVT_TOKEN` |
| pve-kvt-l-03 | https://192.168.20.153:8006/ | `HOMEPAGE_VAR_PVE_KVT_TOKEN` |
| pve-local-l-01 | https://10.0.1.101:8006/ | `HOMEPAGE_VAR_PVE_LOCAL_L_01_TOKEN` |
| pve-local-l-02 | https://192.168.20.154:8006/ | `HOMEPAGE_VAR_PVE_LOCAL_L_02_TOKEN` |

The three KVT nodes form one cluster and share a single token.

### Widget shape in services.yaml

```yaml
widget:
    type: proxmox
    url: https://<node-ip>:8006/
    username: api@pve!homepage
    password: {{HOMEPAGE_VAR_<NAME>}}
    node: <node-name>
```

## Custom Styling

Custom CSS (`custom.css`) and JS (`custom.js`) add:
- Dot pattern background overlay
- Gradient glow effect (center)
- Glass-style backdrop blur on service cards
- Hover glow effect on cards
- Active tab highlighting
