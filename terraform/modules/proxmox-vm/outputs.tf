output "vm_ipv4_address" {
  description = "Статический IPv4 ВМ из cloud-init конфигурации (без CIDR-маски)"
  value       = split("/", var.ipv4_address)[0]
}
