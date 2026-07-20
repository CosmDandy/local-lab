locals {
  clone_full   = true
  gateway      = "192.168.82.1"
  ci_user      = "cluster"
  ci_user_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsx73RvU7CaBdKkAcRXcLdIG/APXzi5l4sxY+5J57EV cosmdandy@macbook-cosmdandy", "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHOzZ8Ak8bAurUe2KsVpYHV83DOsYfDzNyWVyVEhT+wT1Qd06idbib/kvWiht373tn+SrjSHzW2PYX7gRKorEcyIidJRxRK1YGB5l/InZn8LVRQVvmkGK2b96bXyREIlYNZIEAzv8xEBWrO/d14Dvb6uqSmBgaujKqWkbHsBZGnAwbWQ39/7+0jHeRECWMsunQTgscSpXpTnkCeAoxldpCbHMWWS9eUlHxo3bGcoVICB73oz3DFItjUVH69REYI54ixlMvjY6eV+xAjowFeD2QmAgw9RjaDwsrW9PleqtukWn7GUGgshReaN6249fYhSrQGCZkNpLI2wG4/h4JbGlhFtYu1wZmecRKIquTf5p6soRMPGt9bKyShW6j3qe6IK5d9nbV5+q8XQLR1Tq54a4MZATi8rbTAkvnlpm3uc4ObKqNzcJQ0khuc26oO1288k4joUoLwMFsuacOsCY1tYcdOVrzracewREmVQWw4X3Y7q+eGBWe8cEChC5bRrG9DtgO9wW3kXqgpL5/qXoiRdKHB8SI4KXhrUekDtLRYJVtvmlI0UB2kxqZhENN8KlpQyDXq3G24NGLCdU+3bHKIdxTHr7lnFbOv/QVUVujzhpoKSlAtfrwZo8uQXK9GtO/hqoJ8F7ugOnLgapGhzqLOjURbUg5C8hmaF0oOIDMIxVzCQ== veek47@ya.ru"]
  dns_servers  = ["1.1.1.1", "8.8.8.8"]
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
  dns_servers       = local.dns_servers
  cores             = each.value.cores
  type              = local.cpu_type
  memory            = each.value.memory
  os_disk           = each.value.os_disk
  data_disks        = each.value.data_disks
}
