variable "proxmox_api_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

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

variable "proxmox_node_name" {
  type = string
}

variable "gateway" {
  type = string
}

variable "kubeconfig_path" {
  type    = string
  default = null
}

variable "talosconfig_path" {
  type    = string
  default = null
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
