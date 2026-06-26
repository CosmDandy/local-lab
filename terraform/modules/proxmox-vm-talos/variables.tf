variable "vm_id" {
  type = number
}

variable "vm_name" {
  type = string
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

variable "disk_size" {
  type    = number
  default = 8
}

variable "image_import_id" {
  type    = string
  default = "local:import/talos-v1.13.5-nocloud-amd64.raw"
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
  }))
  default = []
}
