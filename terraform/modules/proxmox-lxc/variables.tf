variable "node_name" {
  type = string
}
variable "vm_id" {
  type = string
}
variable "unprivileged" {
  type    = bool
  default = true
}
variable "tags" {
  type = set(string)
}

# OS
variable "os_template" {
  type = string
}
variable "os_type" {
  type = string
}

# Resouces
variable "cpu" {
  type    = number
  default = 2
}
variable "cpu_arch" {
  type    = string
  default = "amd64"
}
variable "memory" {
  type    = number
  default = 2048
}
variable "swap" {
  type    = number
  default = 512
}

# Disk
variable "disk_id" {
  type = string
}
variable "disk_size" {
  type    = number
  default = 10
}

# Network
variable "hostname" {
  type = string
}
variable "ipv4" {
  type    = string
  default = "dhcp"
}
variable "gateway" {
  type = string
}
variable "dns" {
  # Принимает как строку ("10.0.1.1"), так и список (["10.0.1.1", "1.1.1.1"])
  type    = any
  default = []
}

# Features
variable "features" {
  type = object({
    nesting = optional(bool, false)
    fuse    = optional(bool, false)
    keyctl  = optional(bool, false)
    mount   = optional(string)
  })
  default = {}
}
