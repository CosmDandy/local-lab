terraform {
  required_version = "~> 1.0"
  cloud {
    organization = "CosmDandy"

    workspaces {
      project = "kvt-lab"
      name    = "kvt-lab-talos-k8s-3c-3w"
    }
  }
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
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
