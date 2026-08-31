# pve-kvt-l-01

Office site, Proxmox VE node. Cluster: `pve-kvt-l` (3 nodes).
Formerly documented as **kaluga**. Most capable node of the office cluster.

## Chassis

| | |
|---|---|
| Vendor / model | Micro-Star International (MSI) MS-7B84, desktop |
| Motherboard | MSI B450M PRO-M2 MAX |
| BIOS | AMI A.50, 2019-12-03 |
| Form factor | Desktop tower, consumer-grade |

## CPU

| | |
|---|---|
| Model | AMD Ryzen 7 2700 (Zen+, family 17h) |
| Topology | 1 socket, 8 cores, 16 threads, single NUMA node |
| Clocks | 1.55 GHz base scaling floor, 3.20 GHz max |
| Cache | L1d 256 KiB, L1i 512 KiB, L2 4 MiB, L3 16 MiB |
| Virtualization | AMD-V (SVM), IOMMU present |

## Memory

64 GiB total, 2 of 2 DIMM slots populated — **no room to expand without replacing modules**.

| Slot | Size | Type | Speed | Vendor | Part |
|---|---|---|---|---|---|
| DIMM 0 | 32 GB | DDR4 | 2933 MT/s | Kingston | KF3600C18D4/32GX |
| DIMM 1 | 32 GB | DDR4 | 2933 MT/s | Kingston | KF3600C18D4/32GX |

Non-ECC consumer memory. Rated 3600 MT/s, running at 2933.

## Storage

| Device | Size | Type | Model | Role |
|---|---|---|---|---|
| nvme0n1 | 477 GiB | NVMe SSD | Intel SSDPEKNW512G8 (660p, QLC) | Boot — ESP, `pve-root` 96 G, `local-lvm` 349 G |
| sdb | 932 GiB | SATA SSD | Samsung 870 EVO 1TB | `ssd-lvm` thin pool 885 G — VM disks |
| sda | 447 GiB | SATA SSD | Seagate Nytro XA480LE10063 (enterprise) | **Unallocated** |
| sdc | 1.8 TiB | SATA HDD, 5400 rpm | WDC WD20EFRX (Red, CMR) | **Unallocated** |

All four drives report SMART health PASSED.

> Two idle drives here: an enterprise SATA SSD and a 2 TB CMR HDD. The HDD is the obvious
> backup target for the cluster; the Nytro is the fastest sustained-write device in the fleet.

## Network

| | |
|---|---|
| NIC | Realtek RTL8111/8168/8211/8411 1 GbE (onboard) |
| Bridge | `vmbr0` → 192.168.20.151/24 |
| Overlay | Tailscale, 100.64.0.5 |
| Interfaces | `mgmt` (renamed onboard NIC) enslaved to `vmbr0` |
| BMC | none — consumer board, no out-of-band management |

## GPU

AMD Radeon RX 470/480/570/580 (Ellesmere) + HDMI audio. Currently unused by guests —
a PCI-passthrough candidate.

## Software

| | |
|---|---|
| OS | Debian GNU/Linux 13 (trixie) |
| Proxmox | pve-manager 9.2.10 |
| Kernel | 7.0.14-11-pve |

## Storage pools

| Pool | Type | Total | Used |
|---|---|---|---|
| `local` | dir | 94 GiB | 10.3 % |
| `local-lvm` | lvmthin | 349 GiB | 0 % |
| `ssd-lvm` | lvmthin | 885 GiB | 0.74 % |

## Guests

| ID | Name | Kind | RAM | Boot disk |
|---|---|---|---|---|
| 161 | talos-k8s-master-01 | VM | 8 GB | 32 G |
| 164 | talos-k8s-worker-01 | VM | 16 GB | 32 G |
| 100 | testbed-l-01 | LXC | — | 16 G |
