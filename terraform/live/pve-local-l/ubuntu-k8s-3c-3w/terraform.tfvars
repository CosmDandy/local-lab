vms = {
  "ubuntu-k8s-master-01" = {
    ipv4_address = "10.0.1.111/24"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "ubuntu-k8s-master-02" = {
    ipv4_address = "10.0.1.112/24"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "ubuntu-k8s-master-03" = {
    ipv4_address = "10.0.1.113/24"
    cores        = 4
    memory       = 8192
    disk_size    = 32
  }
  "ubuntu-k8s-worker-01" = {
    ipv4_address = "10.0.1.121/24"
    cores        = 4
    memory       = 16384
    disk_size    = 32
  }
  "ubuntu-k8s-worker-02" = {
    ipv4_address = "10.0.1.122/24"
    cores        = 4
    memory       = 16384
    disk_size    = 32
  }
  "ubuntu-k8s-worker-03" = {
    ipv4_address = "10.0.1.123/24"
    cores        = 4
    memory       = 16384
    disk_size    = 32
  }
}
