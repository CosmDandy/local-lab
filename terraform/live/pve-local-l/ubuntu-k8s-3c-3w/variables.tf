variable "proxmox_node" {
  type    = string
  default = "10.0.1.101" # IP твоей Proxmox-ноды
}

variable "proxmox_node_name" {
  type    = string
  default = "pve-local-l-01"
}

variable "proxmox_node_ip" {
  type    = string
  default = "10.0.1.101"
}

variable "template_id" {
  type    = number
  default = 9000
}

variable "gateway" {
  type    = string
  default = "10.0.1.1"
}

variable "tags" {
  type    = set(string)
  default = ["k8s", "terraform"]
}

variable "vms" {
  type = map(object({
    ipv4_address = string
    cores        = optional(number, 2)
    memory       = optional(number, 2048)
    disk_size    = optional(number, 8)
  }))
}
