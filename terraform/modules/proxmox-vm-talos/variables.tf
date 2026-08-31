variable "vm_id" {
  type = number
}

variable "vm_name" {
  type = string
}

variable "vm_description" {
  type    = string
  default = ""
}

variable "proxmox_node_name" {
  type    = string
  default = "pve-local-l-01"
}

variable "tags" {
  type    = set(string)
  default = []
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "vlan_id" {
  type     = number
  default  = null
  nullable = true
}

variable "firewall" {
  type    = bool
  default = false
}

variable "firewall_security_groups" {
  type    = list(string)
  default = []
}

variable "os_disk" {
  type = object({
    datastore_id = optional(string, "local-lvm")
    size         = optional(number, 8)
    ssd          = optional(bool, true)
  })
  default = {}
}

variable "image_file_id" {
  type = string
}

variable "ipv4_cidr" {
  type = string
}

variable "gateway" {
  type    = string
  default = "10.0.1.1"
}

variable "data_disks" {
  description = "Дополнительные (data) диски ВМ, напр. под Longhorn. Пустой список — только OS-диск."
  type = list(object({
    datastore_id = string
    size         = number
    ssd          = optional(bool, true)
  }))
  default = []
}
