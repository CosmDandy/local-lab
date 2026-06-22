output "ipv4_addresses" {
  value = {
    for name, vm in module.node :
    name => vm.vm_ipv4_address
  }
}
