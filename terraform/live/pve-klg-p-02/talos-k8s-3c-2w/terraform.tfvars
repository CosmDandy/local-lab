cluster_name       = "kvt-lab"
talos_version      = "v1.13.5"
talos_schematic_id = "5be72c148a4108b6449f245102d2eea965811505ecbc6c84984c5f8b8628c8be"
proxmox_node_name  = "node2"
gateway            = "192.168.82.1"
vms = {
  "talos-k8s-master-01" = {
    ipv4_address = "192.168.82.151"
    role         = "controlplane"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "talos-k8s-master-02" = {
    ipv4_address = "192.168.82.152"
    role         = "controlplane"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "talos-k8s-master-03" = {
    ipv4_address = "192.168.82.153"
    role         = "controlplane"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "talos-k8s-worker-01" = {
    ipv4_address = "192.168.82.154"
    role         = "worker"
    cores        = 4
    memory       = 16384
    disk_size    = 32
    data_disks   = [{ datastore_id = "local-zfs", size = 100 }]
  }
  "talos-k8s-worker-02" = {
    ipv4_address = "192.168.82.155"
    role         = "worker"
    cores        = 4
    memory       = 16384
    disk_size    = 32
    data_disks   = [{ datastore_id = "local-zfs", size = 100 }]
  }
  "talos-k8s-worker-03" = {
    ipv4_address = "192.168.82.156"
    role         = "worker"
    cores        = 4
    memory       = 16384
    disk_size    = 32
    data_disks   = [{ datastore_id = "local-zfs", size = 100 }]
  }
}
