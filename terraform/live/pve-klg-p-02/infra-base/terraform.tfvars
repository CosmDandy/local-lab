vms = {
  "traefik" = {
    ipv4_address      = "192.168.82.130/24"
    vm_tags           = ["traefik", "proxy", "base"]
    proxmox_node_name = "node2"
    cores             = 2
    memory            = 2048
    os_disk = {
      datastore_id = "local-zfs"
      size         = 10
      ssd          = true
    }
  }
  "authentik" = {
    ipv4_address      = "192.168.82.131/24"
    vm_tags           = ["authentik", "sso", "base"]
    proxmox_node_name = "node2"
    cores             = 2
    memory            = 4096
    os_disk = {
      datastore_id = "local-zfs"
      size         = 16
      ssd          = true
    }
  }
  "gitlab" = {
    ipv4_address      = "192.168.82.132/24"
    vm_tags           = ["gitlab", "scm", "base"]
    proxmox_node_name = "node2"
    cores             = 4
    memory            = 8192
    os_disk = {
      datastore_id = "local-zfs"
      size         = 25
      ssd          = true
    }
    data_disks = [
      {
        datastore_id = "local-zfs"
        size         = 150
        ssd          = true
      }
    ]
  }
  "seaweedfs" = {
    ipv4_address      = "192.168.82.133/24"
    vm_tags           = ["seaweedfs", "s3", "storage", "base"]
    proxmox_node_name = "node2"
    cores             = 4
    memory            = 4096
    os_disk = {
      datastore_id = "local-zfs"
      size         = 16
      ssd          = true
    }
    data_disks = [
      {
        datastore_id = "local-zfs"
        size         = 150
        ssd          = true
      }
    ]
  }
  "opensearch" = {
    ipv4_address      = "192.168.82.134/24"
    vm_tags           = ["opensearch", "logs", "observability", "base"]
    proxmox_node_name = "node2"
    cores             = 4
    memory            = 8192
    os_disk = {
      datastore_id = "local-zfs"
      size         = 20
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
  "victoria-metrics" = {
    ipv4_address      = "192.168.82.135/24"
    vm_tags           = ["victoria-metrics", "metrics", "observability", "base"]
    proxmox_node_name = "node2"
    cores             = 2
    memory            = 4096
    os_disk = {
      datastore_id = "local-zfs"
      size         = 16
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
  "gatus" = {
    ipv4_address      = "192.168.82.136/24"
    vm_tags           = ["gatus", "uptime", "observability", "base"]
    proxmox_node_name = "node2"
    cores             = 1
    memory            = 1024
    os_disk = {
      datastore_id = "local-zfs"
      size         = 8
      ssd          = true
    }
  }
  "databasus" = {
    ipv4_address      = "192.168.82.137/24"
    vm_tags           = ["databasus", "backup", "base"]
    proxmox_node_name = "node2"
    cores             = 4
    memory            = 8192
    os_disk = {
      datastore_id = "local-zfs"
      size         = 16
      ssd          = true
    }
    data_disks = [
      {
        datastore_id = "local-zfs"
        size         = 200
        ssd          = true
      }
    ]
  }
}
