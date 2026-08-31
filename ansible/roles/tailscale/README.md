# Tailscale role

Installs Tailscale from a release tarball rather than the upstream apt repository, so the
target host needs no internet access of its own — Ansible ships the binaries over SSH.

## Required files (not in git)

The tarballs are 61 MB of binaries and are excluded via `.gitignore`. Fetch them before the
first run:

```bash
V=1.90.9   # must match tailscale_version in defaults/main.yml
cd ansible/roles/tailscale/files
curl -fLO "https://pkgs.tailscale.com/stable/tailscale_${V}_amd64.tgz"
curl -fLO "https://pkgs.tailscale.com/stable/tailscale_${V}_arm.tgz"   # only for arm hosts
```

`tailscale_arch` selects which one is used; `amd64` by default, `arm` for the Raspberry Pi.

## Operations

`tailscale_operation` picks the task file: `install-full` (default), `install`, `authorize`,
`deauthorize`, `update`, `uninstall`.

## Variables worth setting

| Variable | Purpose |
|---|---|
| `tailscale_authkey` | Auth key; authorization is skipped when empty |
| `tailscale_advertise_routes` | Subnets to advertise, e.g. `192.168.20.0/24` |
| `tailscale_advertise_exit_node` | Offer the host as an exit node |
| `tailscale_accept_routes` | Accept subnet routes from other nodes |
| `tailscale_login_server` | Headscale URL; empty means Tailscale's own control plane |

Imported from the retired `lab-home` repository, 2026-08-29.
