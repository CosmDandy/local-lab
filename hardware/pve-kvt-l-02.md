# pve-kvt-l-02

Office site, Proxmox VE node. Cluster: `pve-kvt-l` (3 nodes).
The only purpose-built server chassis in the office cluster.

## Chassis

| | |
|---|---|
| Vendor / model | Lenovo ThinkSystem ST50, 7Y48CTO1WW |
| Motherboard | Lenovo, board 3138 |
| BIOS | Lenovo ITE105C, 2019-11-02 |
| Form factor | Tower server |

## CPU

| | |
|---|---|
| Model | Intel Xeon E-2144G (Coffee Lake) |
| Topology | 1 socket, 4 cores, 8 threads, single NUMA node |
| Clocks | 3.60 GHz base, 4.50 GHz turbo |
| Virtualization | VT-x |

## Memory

32 GiB total, 4 of 4 DIMM slots populated — **full, expansion means replacing modules**.

| Size | Type | Rated | Vendor | Part |
|---|---|---|---|---|
| 8 GB | DDR4 ECC | 2666 MT/s | SK Hynix | HMA81GU7CJR8N-VK |
| 8 GB | DDR4 | 2666 MT/s | SK Hynix | HMA81GU6CJR8N-VK |
| 8 GB | DDR4 ECC | 2666 MT/s | SK Hynix | HMA81GU7DJR8N-VK |
| 8 GB | DDR4 | 2400 MT/s | Kingston | 9965684-005.A00G |

> Mixed kit: three Hynix modules of three different part numbers plus one Kingston, and the
> set includes both ECC (`U7`) and non-ECC (`U6`) parts. All four run at 2400 MT/s — the
> slowest module sets the bus. Least RAM in the fleet on a board that cannot take more.

## Storage

| Device | Size | Type | Model | Role |
|---|---|---|---|---|
| sda | 112 GiB | SATA SSD | Kingston SUV400S37120G | Boot — `pve-root` 37 G, `local-lvm` 49 G |
| sdb | 932 GiB | SATA SSD | Samsung 870 EVO 1TB | `ssd-lvm` thin pool 885 G — VM disks |
| sr0 | — | USB ODD | DVDRAM GP75N | External optical drive |

## Network

| | |
|---|---|
| NIC | Intel I219-LM 1 GbE (onboard) |
| Bridge | `vmbr0` → 192.168.20.152/24 |
| Overlay | Tailscale, 100.64.0.6 |
| BMC | none configured (ST50 has no onboard XCC) |

## GPU

Intel UHD Graphics P630 (integrated). No discrete GPU.

## Software

| | |
|---|---|
| OS | Debian GNU/Linux 13 (trixie) |
| Proxmox | pve-manager 9.2.10 |
| Kernel | 7.0.14-11-pve |

## Storage pools

| Pool | Type | Total | Used |
|---|---|---|---|
| `local` | dir | 37 GiB | 26.4 % |
| `local-lvm` | lvmthin | 49 GiB | 0 % |
| `ssd-lvm` | lvmthin | 885 GiB | 0.66 % |

## Guests

| ID | Name | Kind | RAM | Boot disk |
|---|---|---|---|---|
| 162 | talos-k8s-master-02 | VM | 8 GB | 32 G |
| 165 | talos-k8s-worker-02 | VM | 16 GB | 32 G |

> 24 GB of the 32 GB is committed to guests. This node is the memory bottleneck of the
> office cluster.
