output "vm_ipv4_address" {
  value = one(setsubtract(flatten(proxmox_virtual_environment_vm.vm.ipv4_addresses), ["127.0.0.1"]))
}
