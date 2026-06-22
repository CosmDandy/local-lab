output "vm_ipv4_address" {
  value = split("/", var.ipv4_cidr)[0]
}
