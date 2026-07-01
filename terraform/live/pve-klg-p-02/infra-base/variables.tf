variable "proxmox_api_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "vms" {
  type = map(object({
    ipv4_address      = string
    vm_tags           = list(string)
    proxmox_node_name = string
    cores             = number
    memory            = number
    os_disk = object({
      datastore_id = string
      size         = number
      ssd          = bool
    })
    data_disks = optional(list(object({
      datastore_id = string
      size         = number
      ssd          = bool
    })), [])
  }))
}
