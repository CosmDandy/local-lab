vms = {
  "nexus" = {
    ipv4_address      = "192.168.82.104/24"
    vm_tags           = ["nexus", "registry", "bootstrap"]
    proxmox_node_name = "node2"
    dns_servers       = ["1.1.1.1", "8.8.8.8"]
    cores             = 4
    memory            = 8192
    os_disk = {
      datastore_id = "local-zfs"
      size         = 32
      ssd          = true
    }
    data_disks = [
      {
        datastore_id = "local-zfs"
        size         = 100
        ssd          = true
      }
    ]
  }
}
