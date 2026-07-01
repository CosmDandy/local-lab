resource "proxmox_download_file" "cloud_image" {
  content_type = "iso"
  datastore_id = var.image_datastore
  node_name    = var.node_name
  url          = var.image_url
}

resource "proxmox_virtual_environment_vm" "template" {
  name      = var.template_name
  vm_id     = var.vm_id
  node_name = var.node_name
  template  = true
  started   = false

  description = "Managed by Terraform"
  machine     = var.firmware == "uefi" ? "q35" : null
  bios        = var.firmware == "uefi" ? "ovmf" : "seabios"

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  scsi_hardware = "virtio-scsi-single"

  dynamic "efi_disk" {
    for_each = var.firmware == "uefi" ? [1] : []
    content {
      datastore_id      = var.datastore_id
      type              = "4m"
      pre_enrolled_keys = var.secure_boot
    }
  }

  disk {
    file_id      = proxmox_download_file.cloud_image.id
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    iothread     = true
    ssd          = var.ssd
    discard      = "on"
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = var.bridge
  }
}
