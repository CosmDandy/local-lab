# Hardware inventory

Collected 2026-08-29 from the live machines over SSH. One file per Proxmox node, named
after the node's hostname.

| File | Contents |
|---|---|
| `<node>.md` | Curated inventory — chassis, CPU, memory layout, disks and their roles, network, BMC, guests |
| `<node>.lshw.txt` | Raw `lshw` output, unmodified |

## Fleet

| Node | Site | Chassis | CPU | Threads | RAM | VM storage | Guests |
|---|---|---|---|---|---|---|---|
| [pve-kvt-l-01](./pve-kvt-l-01.md) | office | MSI B450M desktop | Ryzen 7 2700 | 16 | 64 GB | 885 G | 2 VM + 1 CT |
| [pve-kvt-l-02](./pve-kvt-l-02.md) | office | Lenovo ThinkSystem ST50 | Xeon E-2144G | 8 | 32 GB | 885 G | 2 VM |
| [pve-kvt-l-03](./pve-kvt-l-03.md) | office | Dell PowerEdge T30 | Xeon E3-1225 v5 | 4 | 64 GB | 425 G | 2 VM |
| [pve-local-l-01](./pve-local-l-01.md) | home | IBM System x3550 M3 | 2 × Xeon X5675 | 24 | 96 GB ECC | 338 G | — |
| [pve-local-l-02](./pve-local-l-02.md) | office subnet | HP ProLiant DL380 G7 | 2 × Xeon X5650 | 24 | 144 GB ECC | 49 G | — |

**Totals:** 76 threads, 400 GB RAM. Of that, 48 threads and 240 GB sit idle on the two
`pve-local-*` nodes, which run no guests at all.

Nodes `pve-kvt-l-01..03` form the `pve-kvt-l` Proxmox cluster and carry the Talos
Kubernetes VMs. Proxmox 9.2.10 on all three; the two `pve-local-*` nodes run 9.2.11.

## Renamed since the previous inventory

The old files used location nicknames. Mapping, by chassis serial and board:

| Old name | Current node |
|---|---|
| kaluga | `pve-kvt-l-01` |
| saint-tropez | `pve-kvt-l-03` |
| beast | `pve-local-l-01` |
| courchevel | no longer in the fleet — the Xeon E3-1225 v3 box is gone |

`pve-kvt-l-02` (Lenovo ST50, Xeon E-2144G) has no counterpart in the old inventory.

## Open points

1. **`pve-local-l-02` is on the office subnet** (192.168.20.154/24) despite the `local`
   name, and has no Tailscale — it is reachable only from inside the office LAN, unlike
   every other node.
2. **`pve-local-l-02` flaps.** During collection SSH answered, then timed out repeatedly,
   while its iLO stayed reachable throughout — so the chassis has power and the fault is
   in the host, not the network.
3. **Its disk health is invisible.** The single 112 GiB volume sits behind an HP Smart
   Array G6; `smartctl` sees nothing through it and `ssacli` is not installed.
4. **Idle capacity.** Both `pve-local-*` nodes are empty; `pve-local-l-01` additionally has
   three unallocated 500 GB SSDs and six free DIMM slots.
5. **Unused NICs.** Both rack servers use 1 of their 4 gigabit ports.

## BMC access

Only the two rack servers have a BMC, and both are too old for a modern browser to reach
directly. Bridges for them live in [`docker/`](../docker/):

| Node | BMC | Address | Bridge |
|---|---|---|---|
| `pve-local-l-01` | IBM IMM, firmware 1.55 | 10.0.1.100 | [`imm-bridge/`](../docker/imm-bridge/compose.yaml) → http://127.0.0.1:8070 |
| `pve-local-l-02` | HP iLO 3, firmware 1.94 | 192.168.20.207 (DHCP) | [`ilo-bridge/`](../docker/ilo-bridge/compose.yaml) → http://127.0.0.1:8443 |
