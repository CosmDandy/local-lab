output "registry_server_ips" {
  description = "IP DNS-серверов (dns-01/02) для использования в других слоях"
  value = one([
    for name, vm in var.vms : split("/", vm.ipv4_address)[0]
    if contains(vm.vm_tags, "registry")
  ])
}

output "template_id" {
  description = "ID Ubuntu-template для клонирования в других слоях"
  value       = module.template.template_id
}
