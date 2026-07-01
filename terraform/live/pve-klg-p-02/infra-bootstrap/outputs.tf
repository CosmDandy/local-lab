output "dns_server_ips" {
  description = "IP DNS-серверов (dns-01/02) для использования в других слоях"
  value = [
    for name, vm in var.vms : split("/", vm.ipv4_address)[0]
    if contains(vm.vm_tags, "dns")
  ]
}

output "registry_server_ips" {
  description = "IP DNS-серверов (dns-01/02) для использования в других слоях"
  value = one([
    for name, vm in var.vms : split("/", vm.ipv4_address)[0]
    if contains(vm.vm_tags, "registry")
  ])
}
