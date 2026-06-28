resource "proxmox_virtual_environment_vm" "vm" {
  vm_id       = var.vm_id
  name        = var.vm_name
  description = var.vm_description
  tags        = var.vm_tags
  node_name   = var.proxmox_node_name
  on_boot     = true

  clone {
    full  = var.clone_full
    vm_id = var.template_id
  }

  agent {
    enabled = true
  }

  network_device {
    bridge   = var.bridge
    vlan_id  = var.vlan_id
    firewall = var.firewall
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.gateway
      }
    }
    user_account {
      username = var.ci_user
      keys     = var.ci_user_keys
    }
    dns {
      servers = var.dns_servers
    }
  }

  cpu {
    cores = var.cores
    type  = var.type
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.os_disk.datastore_id
    interface    = "scsi0"
    size         = var.os_disk.size
    iothread     = true
    ssd          = var.os_disk.ssd
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
      discard      = "on"
    }
  }

  vga {
    type = "serial0"
  }
}

resource "proxmox_virtual_environment_firewall_options" "vm" {
  node_name     = var.proxmox_node_name
  vm_id         = proxmox_virtual_environment_vm.vm.vm_id
  enabled       = var.firewall
  input_policy  = "DROP"
  output_policy = "ACCEPT"
}

resource "proxmox_virtual_environment_firewall_rules" "vm" {
  node_name = var.proxmox_node_name
  vm_id     = proxmox_virtual_environment_vm.vm.vm_id
  dynamic "rule" {
    for_each = var.firewall_security_groups
    content {
      security_group = rule.value
    }
  }
}
