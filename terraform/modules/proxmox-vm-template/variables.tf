variable "node_name" {
  description = "Имя Proxmox-ноды, где создаётся шаблон"
  type        = string
}

variable "template_name" {
  description = "Имя VM-шаблона"
  type        = string
}

variable "vm_id" {
  description = "ID шаблона. null — Proxmox назначит сам"
  type        = number
  default     = null
}

variable "image_url" {
  description = "URL cloud-образа (любой дистрибутив: Ubuntu/Debian/...)"
  type        = string
}

variable "image_datastore" {
  description = "Datastore для скачанного образа (content=iso)"
  type        = string
  default     = "local"
}

variable "datastore_id" {
  description = "Datastore для диска шаблона и efi_disk"
  type        = string
  default     = "local-lvm"
}

variable "cores" {
  description = "vCPU шаблона (наследуется клоном, если тот не переопределит)"
  type        = number
  default     = 2
}

variable "memory" {
  description = "RAM шаблона, МБ"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Размер OS-диска шаблона, ГБ"
  type        = number
  default     = 8
}

variable "ssd" {
  description = "Флаг SSD диска"
  type        = bool
  default     = true
}

variable "bridge" {
  description = "Сетевой мост"
  type        = string
  default     = "vmbr0"
}

variable "firmware" {
  description = "Тип прошивки: uefi (q35+ovmf+efi_disk) или bios (seabios)"
  type        = string
  default     = "uefi"
  validation {
    condition     = contains(["uefi", "bios"], var.firmware)
    error_message = "firmware должен быть \"uefi\" или \"bios\"."
  }
}

variable "secure_boot" {
  description = "Pre-enroll ключей Secure Boot (только при firmware=uefi). Для Ubuntu (подписан MS) грузится из коробки"
  type        = bool
  default     = false
}
