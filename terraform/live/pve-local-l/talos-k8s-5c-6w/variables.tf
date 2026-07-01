variable "proxmox_api_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_node_name" {
  type    = string
  default = "pve-local-l-01"
}

variable "gateway" {
  type    = string
  default = "10.0.1.1"
}

variable "vms" {
  type = map(object({
    ipv4_address = string
    role         = string
    cores        = optional(number, 2)
    memory       = optional(number, 2048)
    disk_size    = optional(number, 8)
    data_disks = optional(list(object({
      datastore_id = string
      size         = number
    })), [])
  }))
}
