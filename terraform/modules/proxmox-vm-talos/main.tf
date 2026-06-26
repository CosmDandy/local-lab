resource "proxmox_virtual_environment_vm" "talos-vm" {
  vm_id           = var.vm_id
  name            = var.vm_name
  node_name       = var.proxmox_node_name
  tags            = var.tags
  on_boot         = true
  boot_order      = ["scsi0"]
  stop_on_destroy = true

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.disk_size
    import_from  = var.image_import_id
  }

  dynamic "disk" {
    for_each = var.data_disks
    content {
      datastore_id = disk.value.datastore_id
      interface    = "scsi${disk.key + 1}"
      size         = disk.value.size
      discard      = "on" # thin: вернуть освобождённые блоки в ZFS-пул
    }
  }

  initialization {
    datastore_id = "local-lvm"
    ip_config {
      ipv4 {
        address = var.ipv4_cidr
        gateway = var.gateway
      }
    }
  }
}
