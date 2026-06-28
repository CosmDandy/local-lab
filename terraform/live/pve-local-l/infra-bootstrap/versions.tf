terraform {
  required_version = "~> 1.0"
  cloud {
    organization = "CosmDandy"

    workspaces {
      project = "local-lab"
      name    = "infra-bootstrap"
    }
  }
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.110"
    }
  }
}
