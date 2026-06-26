locals {
  # var.dns может быть строкой или списком — нормализуем к списку
  dns_servers = try(tolist(var.dns), [var.dns])
}

resource "proxmox_virtual_environment_container" "this" {
  node_name     = var.node_name
  vm_id         = var.vm_id
  unprivileged  = var.unprivileged
  started       = true
  start_on_boot = true
  tags          = var.tags

  # --- ОС / шаблон ---
  operating_system {
    template_file_id = var.os_template
    type             = var.os_type
  }

  # --- ресурсы ---
  cpu {
    cores        = var.cpu
    architecture = var.cpu_arch
  }
  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  # --- корневой диск ---
  disk {
    datastore_id = var.disk_id
    size         = var.disk_size
  }

  # дополнительные mount points — блок mount_point {} (можно несколько)

  # --- сеть (повторяемый блок) ---
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
    # vlan_id = 10
    # firewall = true
  }

  # --- IP/DNS (внутри initialization) ---
  initialization {
    hostname = var.hostname
    ip_config {
      ipv4 {
        address = var.ipv4
        gateway = var.gateway
      }
    }
    dns {
      servers = local.dns_servers
    }
  }

  # --- фичи (для privileged/спец-нагрузок) ---
  dynamic "features" {
    for_each = var.features != null ? [var.features] : []
    content {
      nesting = features.value.nesting
      fuse    = features.value.fuse
      keyctl  = features.value.keyctl
      mount   = features.value.mount
    }
  }
}
