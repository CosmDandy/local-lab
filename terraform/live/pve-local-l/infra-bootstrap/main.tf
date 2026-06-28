locals {
  clone_full   = false
  template_id  = 9000
  gateway      = "10.0.1.1"
  ci_user      = "cosmdandy"
  ci_user_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsx73RvU7CaBdKkAcRXcLdIG/APXzi5l4sxY+5J57EV cosmdandy@macbook-cosmdandy"]
  bridge       = "vmbr0"
  firewall     = false
  cpu_type     = "host"
}

module "node" {
  source = "../../../modules/proxmox-vm-ubuntu"

  for_each = var.vms

  vm_id             = tonumber(split(".", split("/", each.value.ipv4_address)[0])[3])
  vm_tags           = each.value.vm_tags
  vm_name           = each.key
  clone_full        = local.clone_full
  template_id       = local.template_id
  proxmox_node_name = each.value.proxmox_node_name
  bridge            = local.bridge
  firewall          = local.firewall
  ipv4_address      = each.value.ipv4_address
  gateway           = local.gateway
  ci_user           = local.ci_user
  ci_user_keys      = local.ci_user_keys
  dns_servers       = each.value.dns_servers
  cores             = each.value.cores
  type              = local.cpu_type
  memory            = each.value.memory
  os_disk           = each.value.os_disk
  data_disks        = each.value.data_disks
}
