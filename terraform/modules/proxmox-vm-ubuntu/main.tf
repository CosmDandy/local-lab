resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  vm_id     = tonumber(split(".", split("/", var.ipv4_address)[0])[3])
  node_name = var.proxmox_node_name
  tags      = var.tags
  on_boot   = true

  clone {
    full  = var.clone_full
    vm_id = var.template_id
  }

  agent {
    enabled = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.gateway
      }
    }
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
  }

  vga {
    type = "serial0"
  }

  provisioner "local-exec" {
    command = "ssh root@${var.proxmox_node_ip} 'qm stop ${self.vm_id} && sleep 10 && qm start ${self.vm_id}'"
  }
}
