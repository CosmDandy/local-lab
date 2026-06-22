
vms = {
  "talos-k8s-master-01" = {
    ipv4_address = "10.0.1.111"
    role         = "controlplane"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "talos-k8s-master-02" = {
    ipv4_address = "10.0.1.112"
    role         = "controlplane"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "talos-k8s-master-03" = {
    ipv4_address = "10.0.1.113"
    role         = "controlplane"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "talos-k8s-worker-01" = {
    ipv4_address = "10.0.1.121"
    role         = "worker"
    cores        = 4
    memory       = 16384
    disk_size    = 32
  }
  "talos-k8s-worker-02" = {
    ipv4_address = "10.0.1.122"
    role         = "worker"
    cores        = 4
    memory       = 16384
    disk_size    = 32
  }
  "talos-k8s-worker-03" = {
    ipv4_address = "10.0.1.123"
    role         = "worker"
    cores        = 4
    memory       = 16384
    disk_size    = 32
  }
}
