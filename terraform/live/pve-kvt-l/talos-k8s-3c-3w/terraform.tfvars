cluster_name       = "kvt-talos-lab"
talos_version      = "v1.13.5"
talos_schematic_id = "5be72c148a4108b6449f245102d2eea965811505ecbc6c84984c5f8b8628c8be"
gateway            = "192.168.20.1"

vms = {
  "talos-k8s-master-01" = {
    ipv4_address      = "192.168.20.161"
    role              = "controlplane"
    proxmox_node_name = "pve-kvt-l-01"
    cores             = 4
    memory            = 8192
    os_disk           = { datastore_id = "ssd-lvm", size = 32 }
  }
  "talos-k8s-master-02" = {
    ipv4_address      = "192.168.20.162"
    role              = "controlplane"
    proxmox_node_name = "pve-kvt-l-02"
    cores             = 4
    memory            = 8192
    os_disk           = { datastore_id = "ssd-lvm", size = 32 }
  }
  "talos-k8s-master-03" = {
    ipv4_address      = "192.168.20.163"
    role              = "controlplane"
    proxmox_node_name = "pve-kvt-l-03"
    cores             = 4
    memory            = 8192
    os_disk           = { datastore_id = "ssd-lvm", size = 32 }
  }
  "talos-k8s-worker-01" = {
    ipv4_address      = "192.168.20.164"
    role              = "worker"
    proxmox_node_name = "pve-kvt-l-01"
    cores             = 4
    memory            = 16384
    os_disk           = { datastore_id = "ssd-lvm", size = 32 }
    data_disks        = [{ datastore_id = "ssd-lvm", size = 100 }]
  }
  "talos-k8s-worker-02" = {
    ipv4_address      = "192.168.20.165"
    role              = "worker"
    proxmox_node_name = "pve-kvt-l-02"
    cores             = 4
    memory            = 16384
    os_disk           = { datastore_id = "ssd-lvm", size = 32 }
    data_disks        = [{ datastore_id = "ssd-lvm", size = 100 }]
  }
  "talos-k8s-worker-03" = {
    ipv4_address      = "192.168.20.166"
    role              = "worker"
    proxmox_node_name = "pve-kvt-l-03"
    cores             = 4
    memory            = 16384
    os_disk           = { datastore_id = "ssd-lvm", size = 32 }
    data_disks        = [{ datastore_id = "ssd-lvm", size = 100 }]
  }
}
