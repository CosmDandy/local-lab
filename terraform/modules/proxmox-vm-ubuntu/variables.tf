# Base
variable "vm_id" {
  type = number
}
variable "vm_name" {
  type = string
}
variable "vm_description" {
  type    = string
  default = "Managed by Terraform"
}
variable "vm_tags" {
  type    = set(string)
  default = []
}
variable "proxmox_node_name" {
  type = string
}

# Clone
variable "clone_full" {
  type = bool
}
variable "template_id" {
  type = number
}

# Network
variable "bridge" {
  type = string
}
variable "vlan_id" {
  type    = number
  default = null
}
variable "firewall" {
  type    = bool
  default = true
}
variable "firewall_security_groups" {
  type    = list(string)
  default = ["ssh"]
}

# Initialization
variable "ipv4_address" {
  type = string
}
variable "gateway" {
  type = string
}
variable "ci_user" {
  type = string
}
variable "ci_user_keys" {
  type = list(string)
}
variable "dns_servers" {
  type = list(string)
}

# Cpu
variable "cores" {
  type    = number
  default = 2
}
variable "type" {
  type    = string
  default = "host"
}

# Memory
variable "memory" {
  type    = number
  default = 2048
}

# OS Disk
variable "os_disk" {
  type = object({
    datastore_id = string
    size         = optional(number, 8)
    ssd          = optional(bool, true)
  })
}

# Data Disk
variable "data_disks" {
  description = "Доп диски"
  type = list(object({
    datastore_id = string
    size         = number
    ssd          = bool
  }))
  default = []
}
