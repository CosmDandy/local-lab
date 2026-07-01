provider "proxmox" {
  endpoint  = var.proxmox_api_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
  ssh {
    agent    = true
    username = "root"
  }
}

provider "talos" {

}

# Рендерит чарт Cilium локально (helm_template), подключение к кластеру не требуется
provider "helm" {}
