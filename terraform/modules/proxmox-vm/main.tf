resource "proxmox_virtual_environment_file" "vendor_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore
  node_name    = var.proxmox_node_name

  source_raw {
    data      = <<-EOT
    #cloud-config
    timezone: Europe/Moscow
    locale: en_US.UTF-8
    ssh_pwauth: false
    package_update: true
    packages:
      - qemu-guest-agent
      - chrony
    write_files:
      - path: /etc/chrony/chrony.conf
        content: |
          server time.cloudflare.com iburst nts
          pool 0.ru.pool.ntp.org iburst
          pool 1.ru.pool.ntp.org iburst
          driftfile /var/lib/chrony/chrony.drift
          ntsdumpdir /var/lib/chrony
          makestep 1.0 3
          rtcsync
          leapsectz right/UTC
    runcmd:
      - systemctl enable --now qemu-guest-agent
      - systemctl disable --now iscsid open-iscsi multipathd || true
      - systemctl restart chrony
    EOT
    file_name = "vendor-${var.vm_name}.yaml"
  }
}

resource "proxmox_virtual_environment_file" "network_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore
  node_name    = var.proxmox_node_name

  source_raw {
    data      = <<-EOT
    version: 2
    ethernets:
      primary:
        match:
          name: "en*"
        dhcp4: false
        addresses:
          - ${var.ipv4_address}
        routes:
          - to: default
            via: ${var.gateway}
        nameservers:
          addresses: [${join(", ", var.dns_servers)}]
          search: [local]
    EOT
    file_name = "network-${var.vm_name}.yaml"
  }
}

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
    datastore_id         = var.os_disk.datastore_id
    vendor_data_file_id  = proxmox_virtual_environment_file.vendor_data.id
    network_data_file_id = proxmox_virtual_environment_file.network_data.id
    user_account {
      username = var.ci_user
      keys     = var.ci_user_keys
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
    type = "std"
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
