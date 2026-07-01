vms = {
  "postgres" = {
    ipv4_address      = "192.168.82.140/24"
    vm_tags           = ["postgres", "database"]
    proxmox_node_name = "node2"
    cores             = 8
    memory            = 32768
    os_disk = {
      datastore_id = "local-zfs"
      size         = 20
      ssd          = true
    }
    data_disks = [
      {
        datastore_id = "local-zfs"
        size         = 300
        ssd          = true
      }
    ]
  }
}
