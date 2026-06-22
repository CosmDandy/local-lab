terraform {
  required_version = "~> 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.110"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}
