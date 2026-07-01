locals {
  clone_full   = false
  gateway      = "192.168.82.1"
  ci_user      = "cosmdandy"
  ci_user_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsx73RvU7CaBdKkAcRXcLdIG/APXzi5l4sxY+5J57EV cosmdandy@macbook-cosmdandy"]
  bridge       = "vmbr0"
  firewall     = false
  cpu_type     = "host"
}

module "template" {
  source = "../../../modules/proxmox-vm-template"

  image_url       = "https://cloud-images.ubuntu.com/releases/resolute/release/ubuntu-26.04-server-cloudimg-amd64.img"
  image_datastore = "local"
  datastore_id    = "local-zfs"
  node_name       = "node2"
  template_name   = "ubuntu-26-04-template"
  secure_boot     = true
}

module "node" {
  source = "../../../modules/proxmox-vm"

  for_each = var.vms

  vm_id             = tonumber(split(".", split("/", each.value.ipv4_address)[0])[3])
  vm_tags           = each.value.vm_tags
  vm_name           = each.key
  clone_full        = local.clone_full
  template_id       = module.template.template_id
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
