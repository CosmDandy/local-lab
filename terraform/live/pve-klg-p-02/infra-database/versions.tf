terraform {
  required_version = "~> 1.0"
  cloud {
    organization = "CosmDandy"

    workspaces {
      project = "kvt-lab"
      name    = "kvt-lab-infra-database"
    }
  }
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.110"
    }
  }
}
