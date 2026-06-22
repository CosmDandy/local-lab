variable "vm_name" {
  type = string
}

variable "proxmox_node_name" {
  type = string
}

variable "proxmox_node_ip" {
  type = string
}

variable "tags" {
  type    = set(string)
  default = []
}

variable "clone_full" {
  type = bool
}

variable "template_id" {
  type = number
}

variable "ipv4_address" {
  type = string
}

variable "gateway" {
  type = string
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
