provider "proxmox" {
  insecure = true
  ssh {
    agent    = true
    username = "root"
  }
}
