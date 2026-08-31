# pve-kvt-l-03

Office site, Proxmox VE node. Cluster: `pve-kvt-l` (3 nodes).
Formerly documented as **saint-tropez**.

## Chassis

| | |
|---|---|
| Vendor / model | Dell PowerEdge T30 |
| Motherboard | Dell 07T4MC |
| BIOS | Dell 1.1.0, 2019-05-21 |
| Form factor | Mini tower, entry-level server |

## CPU

| | |
|---|---|
| Model | Intel Xeon E3-1225 v5 (Skylake) |
| Topology | 1 socket, 4 cores, 4 threads — **no Hyper-Threading** |
| Clocks | 3.30 GHz base, 3.70 GHz turbo |
| Virtualization | VT-x |

## Memory

64 GiB total, 4 of 4 DIMM slots populated — full.

| Size | Type | Rated | Vendor | Part |
|---|---|---|---|---|
| 16 GB | DDR4 | 2400 MT/s | Kingston | KHX3200C16D4/16GX |
| 16 GB | DDR4 | 2400 MT/s | Kingston | KHX3200C16D4/16GX |
| 16 GB | DDR4 | 2400 MT/s | Kingston | KHX3200C16D4/16GX |
| 16 GB | DDR4 | 2400 MT/s | Kingston | KHX3200C16D4/16GX |

Matched HyperX kit, non-ECC, running at 2133 MT/s (chipset limit).

> Most RAM per core in the office cluster: 16 GB per thread. Also the fewest threads — 4.

## Storage

| Device | Size | Type | Model | Role |
|---|---|---|---|---|
| sda | 112 GiB | SATA SSD | Kingston SUV400S37120G | Boot — `pve-root` 37 G, `local-lvm` 49 G |
| sdb | 447 GiB | SATA SSD | Seagate Nytro XA480LE10063 (enterprise) | `ssd-lvm` thin pool 425 G — VM disks |

Smallest VM pool of the three office nodes.

## Network

| | |
|---|---|
| NIC | Intel I219-LM 1 GbE (onboard) |
| Bridge | `vmbr0` → 192.168.20.153/24 |
| Overlay | Tailscale, 100.64.0.7 |
| BMC | none configured |

## GPU

Intel HD Graphics P530 (integrated). No discrete GPU.

## Software

| | |
|---|---|
| OS | Debian GNU/Linux 13 (trixie) |
| Proxmox | pve-manager 9.2.10 |
| Kernel | 7.0.14-11-pve |

## Storage pools

| Pool | Type | Total | Used |
|---|---|---|---|
| `local` | dir | 37 GiB | 26.1 % |
| `local-lvm` | lvmthin | 49 GiB | 0 % |
| `ssd-lvm` | lvmthin | 425 GiB | 1.32 % |

## Guests

| ID | Name | Kind | RAM | Boot disk |
|---|---|---|---|---|
| 163 | talos-k8s-master-03 | VM | 8 GB | 32 G |
| 166 | talos-k8s-worker-03 | VM | 16 GB | 32 G |

> 24 GB committed to guests against 4 CPU threads — this node is CPU-bound, not RAM-bound.
