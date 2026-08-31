# pve-local-l-01

Home site, Proxmox VE node. Previously documented as **beast**.
Enterprise 1U rack hardware from ~2010 — the only node in the fleet with a working BMC.

## Chassis

| | |
|---|---|
| Vendor / model | IBM System x3550 M3, machine type 7944KHG |
| Motherboard | IBM 94Y7614 |
| BIOS | IBM D6E164AUS-1.22, 2018-06-04 |
| Form factor | 1U rack mount |

## CPU

| | |
|---|---|
| Model | 2 × Intel Xeon X5675 (Westmere-EP, 2011) |
| Topology | 2 sockets, 6 cores each, 24 threads total, 2 NUMA nodes |
| Clocks | 3.07 GHz base, 3.19 GHz max |
| Virtualization | VT-x |

Most threads in the fleet, tied with `pve-local-l-02`.

## Memory

96 GiB total, 12 of 18 DIMM slots populated — **6 slots free, room to reach 144 GiB**.

| Count | Size | Type | Speed | Vendor | Part |
|---|---|---|---|---|---|
| 6 | 8 GB | DDR3 Registered ECC | 1333 MT/s | Micron | 36KSF1G72PZ-1G4M1 / -1G4K1 |
| 6 | 8 GB | DDR3 Registered ECC | 1333 MT/s | SK Hynix | HMT31GR7CFR4A-H9 |

Registered ECC — the only ECC memory in the fleet, alongside `pve-local-l-02`.
DDR3 RDIMMs of this generation are cheap secondhand; expansion is low-cost.

## Storage

| Device | Size | Type | Model | Role |
|---|---|---|---|---|
| sda | 466 GiB | SATA SSD | Samsung 870 EVO 500GB | Boot — `pve-root`, `local-lvm` 338 G |
| sdb | 466 GiB | SATA SSD | Transcend TS500GSSD220Q | **Unallocated** |
| sdc | 466 GiB | SATA SSD | Seagate BarraCuda ZA500CM10002 | **Unallocated** |
| sdd | 466 GiB | SATA SSD | Seagate BarraCuda ZA500CM10002 | **Unallocated** |
| sr0 | — | ODD | HL-DT-ST DVDRAM GT30N | Optical drive |

All four SSDs report SMART health PASSED.

> Four identical-capacity SSDs, three of them idle. This is the natural home for a ZFS
> pool — mirror or RAIDZ1 — and the only node in the fleet with enough spindles for one.

## Network

| | |
|---|---|
| NICs | 4 × Broadcom NetXtreme II BCM5709 1 GbE |
| Active | `mgmt` only; `nic1`, `nic2`, `nic3` are DOWN — **3 of 4 ports unused** |
| Bridge | `vmbr0` → 10.0.1.101/24 |
| Overlay | Tailscale, 100.64.0.8 |

### BMC — IBM IMM

| | |
|---|---|
| Address | 10.0.1.100/24, static |
| Firmware | 1.55 |
| IPMI | 2.0 over KCS, `ipmitool` works locally and over LAN |
| Web UI | HTTP only via `docker/imm-bridge/` — the native UI is unreachable from a modern browser |

## GPU

Matrox MGA G200EV (server VGA, console only).

## Software

| | |
|---|---|
| OS | Debian GNU/Linux 13 (trixie) |
| Proxmox | pve-manager 9.2.11 |
| Kernel | 7.0.14-14-pve |

## Storage pools

| Pool | Type | Total | Used |
|---|---|---|---|
| `local` | dir | 94 GiB | 7.3 % |
| `local-lvm` | lvmthin | 338 GiB | 0 % |

## Guests

None. **This node is empty** — 24 threads and 96 GiB of ECC RAM currently doing nothing.
