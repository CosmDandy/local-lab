provider "proxmox" {
  insecure = true
  ssh {
    agent    = true
    username = "root"
  }
}

provider "talos" {

}

# Рендерит чарт Cilium локально (helm_template), подключение к кластеру не требуется
provider "helm" {}
