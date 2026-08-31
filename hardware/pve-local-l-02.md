# pve-local-l-02

Proxmox VE node. Enterprise 2U rack hardware from ~2010.

> **Naming vs. location.** Despite the `local` (home) name, this node sits on the office
> subnet — `vmbr0` is 192.168.20.154/24, alongside the `pve-kvt-l` cluster, while its
> sibling `pve-local-l-01` is on the home subnet 10.0.1.0/24. It also has **no Tailscale**,
> so it is reachable only from inside the office LAN. Both facts are worth resolving.

## Chassis

| | |
|---|---|
| Vendor / model | HP ProLiant DL380 G7 |
| BIOS | HP P67, 2018-05-21 |
| Form factor | 2U rack mount |

## CPU

| | |
|---|---|
| Model | 2 × Intel Xeon X5650 (Westmere-EP, 2010) |
| Topology | 2 sockets, 6 cores each, 24 threads total, 2 NUMA nodes |
| Clocks | 2.67 GHz base, 2.66 GHz sustained |
| Virtualization | VT-x |

## Memory

144 GiB total, 12 of 18 DIMM slots populated — **6 slots free**.

| Count | Size | Type | Rated | Running at | Slots |
|---|---|---|---|---|---|
| 6 | 16 GB | DDR3 ECC | 1600 MT/s | 1333 MT/s | PROC 1/2 DIMM 3A, 6B, 9C |
| 6 | 8 GB | DDR3 ECC | 1333 MT/s | 1333 MT/s | PROC 1/2 DIMM 2D, 5E, 8F |

Upgraded 2026-08-30, from 72 GiB: the 8 GB modules moved into the 4 GB slots and 16 GB
modules took the rest. Balanced across both sockets, one 16 GB module per channel.
Most memory in the fleet.

> The 16 GB modules are rated 1600 MT/s but run at 1333 — the Xeon X5650 tops out at
> DDR3-1333, so that ceiling only moves with different CPUs. Six free slots remain.

## Storage

| Device | Size | Type | Model | Role |
|---|---|---|---|---|
| sda | 112 GiB | SAS, HW RAID logical volume | HP Smart Array G6 | Boot — `pve-root` 38 G, `local-lvm` 49 G |
| sr0 | — | ODD | DV-28S-W | Optical drive |

> **The weak point of this machine.** A single 112 GiB logical volume behind an HP Smart
> Array G6 controller is all the storage there is. The controller hides the physical disks,
> so `smartctl` returns nothing — drive health is invisible without `ssacli`, which is not
> installed. Array layout, disk count and disk health are all currently unknown.

## Network

| | |
|---|---|
| NICs | 4 × Broadcom NetXtreme II BCM5709 1 GbE |
| Active | `mgmt` only; `nic1`, `nic2`, `nic3` are DOWN — **3 of 4 ports unused** |
| Bridge | `vmbr0` → 192.168.20.154/24 |
| Overlay | **none — Tailscale is not installed** |

### BMC — HP iLO 3

| | |
|---|---|
| Address | 192.168.20.207, **assigned by DHCP** |
| Firmware | 1.94 |
| IPMI | reachable via `ipmitool` on the host |
| Web UI | via `docker/ilo-bridge/` — TLS 1.0 / 3DES only, no modern browser will connect directly |

> The iLO takes its address from DHCP, but `docker/ilo-bridge/` hardcodes 192.168.20.207.
> A lease change silently breaks the bridge. Worth a reservation on the router.

## GPU

AMD ES1000 (server VGA, console only).

## Software

| | |
|---|---|
| OS | Debian GNU/Linux 13 (trixie) |
| Proxmox | pve-manager 9.2.11 |
| Kernel | 7.0.14-14-pve |

## Storage pools

| Pool | Type | Total | Used |
|---|---|---|---|
| `local` | dir | 37 GiB | 15.8 % |
| `local-lvm` | lvmthin | 49 GiB | 0 % |

## Guests

None. **This node is empty** — 24 threads and 144 GiB of ECC RAM currently doing nothing.

## Reachability

Intermittent during collection on 2026-08-29: SSH answered, then timed out repeatedly on
192.168.20.154. Worth investigating before this node is given any real workload.
