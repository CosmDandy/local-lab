vms = {
  "dns-01" = {
    ipv4_address      = "10.0.1.102/24"
    vm_tags           = ["dns", "bootstrap"]
    proxmox_node_name = "pve-local-l-01"
    dns_servers       = ["1.1.1.1", "8.8.8.8"]
    cores             = 2
    memory            = 2048
    os_disk = {
      datastore_id = "local-lvm"
      size         = 16
      ssd          = true
    }
  }
  "dns-02" = {
    ipv4_address      = "10.0.1.103/24"
    vm_tags           = ["dns", "bootstrap"]
    proxmox_node_name = "pve-local-l-01"
    dns_servers       = ["1.1.1.1", "8.8.8.8"]
    cores             = 2
    memory            = 2048
    os_disk = {
      datastore_id = "local-lvm"
      size         = 16
      ssd          = true
    }
  }
  "nexus" = {
    ipv4_address      = "10.0.1.104/24"
    vm_tags           = ["nexus", "registry", "bootstrap"]
    proxmox_node_name = "pve-local-l-01"
    dns_servers       = ["10.0.1.102", "10.0.1.103"]
    cores             = 4
    memory            = 8192
    os_disk = {
      datastore_id = "local-lvm"
      size         = 32
      ssd          = true
    }
    data_disks = [
      {
        datastore_id = "tank"
        size         = 100
        ssd          = true
      }
    ]
  }
}
