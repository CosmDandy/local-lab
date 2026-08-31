# Proxmox
variable "proxmox_api_endpoint" {
  type = string
}
variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

# Talos cluster
variable "cluster_name" {
  type = string
}
variable "talos_version" {
  type    = string
  default = "v1.13.5"
}
variable "talos_schematic_id" { # твой набор extensions (qemu-agent, iscsi-tools)
  type = string
}
variable "image_datastore" { # где лежит образ (import-storage)
  type    = string
  default = "local"
}

# Network
variable "gateway" {
  type = string
}

# VMs
variable "vms" {
  type = map(object({
    ipv4_address      = string
    role              = string
    proxmox_node_name = string
    cores             = optional(number, 2)
    memory            = optional(number, 2048)
    os_disk = object({
      datastore_id = optional(string, "ssd-lvm")
      size         = optional(number, 32)
    })
    data_disks = optional(list(object({
      datastore_id = string
      size         = number
    })), [])
  }))
}
