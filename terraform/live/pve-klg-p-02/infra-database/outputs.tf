output "postgres_ip" {
  description = "IP ВМ postgres для использования в других слоях"
  value = one([
    for name, vm in var.vms : split("/", vm.ipv4_address)[0]
    if contains(vm.vm_tags, "postgres")
  ])
}
