resource "proxmox_virtual_environment_vm" "talos-vm" {
  vm_id           = var.vm_id
  name            = var.vm_name
  description     = var.vm_description
  node_name       = var.proxmox_node_name
  tags            = var.tags
  on_boot         = true
  boot_order      = ["scsi0"]
  stop_on_destroy = true
  scsi_hardware   = "virtio-scsi-single"

  agent {
    enabled = true
  }

  network_device {
    bridge   = var.bridge
    vlan_id  = var.vlan_id
    firewall = var.firewall
  }

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.os_datastore_id
    file_id      = var.image_file_id
    interface    = "scsi0"
    size         = var.disk_size
    iothread     = true
    ssd          = var.ssd
    discard      = "on"
  }

  dynamic "disk" {
    for_each = var.data_disks
    content {
      datastore_id = disk.value.datastore_id
      interface    = "scsi${disk.key + 1}"
      size         = disk.value.size
      iothread     = true
      ssd          = disk.value.ssd
      discard      = "on" # thin: вернуть освобождённые блоки в ZFS-пул
    }
  }

  initialization {
    datastore_id = var.os_datastore_id
    ip_config {
      ipv4 {
        address = var.ipv4_cidr
        gateway = var.gateway
      }
    }
  }

  vga {
    type = "std"
  }

}
