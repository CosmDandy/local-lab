module "node" {
  source   = "../../../modules/proxmox-vm"
  for_each = var.vms

  vm_name           = each.key
  proxmox_node_name = var.proxmox_node_name
  tags              = var.tags

  clone_full  = false
  template_id = var.template_id

  ipv4_address = each.value.ipv4_address
  gateway      = var.gateway

  cores = each.value.cores

  memory = each.value.memory

  disk_size = each.value.disk_size

  proxmox_node_ip = var.proxmox_node_ip
}
