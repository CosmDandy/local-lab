module "node" {
  source = "../../../modules/proxmox-vm-talos"

  for_each          = var.vms
  vm_name           = each.key
  vm_id             = tonumber(split(".", split("/", each.value.ipv4_address)[0])[3])
  proxmox_node_name = var.proxmox_node_name
  tags              = ["k8s", "terraform"]
  cores             = each.value.cores
  memory            = each.value.memory
  disk_size         = each.value.disk_size
  ipv4_cidr         = "${each.value.ipv4_address}/24"
  gateway           = var.gateway
  data_disks        = each.value.data_disks
}

locals {
  masters         = { for k, v in var.vms : k => v if v.role == "controlplane" }
  workers         = { for k, v in var.vms : k => v if v.role == "worker" }
  first_master_ip = local.masters[keys(local.masters)[0]].ipv4_address

  # Gateway API CRDs (vendored, pinned v1.4.1) — Cilium их сам не ставит,
  # должны быть в кластере до старта оператора → вшиваем в inlineManifests.
  gateway_crd_dir = "${path.module}/bootstrap/gateway-api-crds"
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = "local-lab"
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in local.masters : v.ipv4_address]
  nodes                = [for k, v in var.vms : v.ipv4_address]
}

data "helm_template" "cilium" {
  name         = "cilium"
  namespace    = "kube-system"
  repository   = "https://helm.cilium.io"
  chart        = "cilium"
  version      = "1.19.5"
  kube_version = "1.36.0" # helm_template рендерит локально и иначе берёт дефолт 1.20, чарт требует >=1.21
  values       = [file("${path.module}/bootstrap/cilium-values.yaml")]
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = "local-lab"
  machine_type     = "controlplane"
  cluster_endpoint = "https://${local.first_master_ip}:6443" # IP первой master
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = "v1.13" # задай явно — рекомендуется

  config_patches = [
    yamlencode({
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = true
        }
        # CRD идут первыми, Cilium последним: к моменту разворачивания
        # Gateway API оператором CRD уже применены.
        inlineManifests = concat(
          [
            for f in sort(tolist(fileset(local.gateway_crd_dir, "*.yaml"))) : {
              name     = trimsuffix(f, ".yaml")
              contents = file("${local.gateway_crd_dir}/${f}")
            }
          ],
          [
            {
              name     = "cilium"
              contents = data.helm_template.cilium.manifest
            }
          ]
        )
      }
      machine = {
        registries = {
          mirrors = {
            "registry.k8s.io" = {
              endpoints    = ["http://10.0.1.50:5000"]
              skipFallback = true
            }
            "docker.io" = {
              endpoints    = ["http://10.0.1.50:5001"]
              skipFallback = true
            }
            "quay.io" = {
              endpoints    = ["http://10.0.1.50:5002"]
              skipFallback = true
            }
          }
        }
        install = {
          disk = "/dev/sda"
        }
      }
    })
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = "local-lab"
  machine_type     = "worker"
  cluster_endpoint = "https://${local.first_master_ip}:6443" # IP первой master
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = "v1.13"

  config_patches = [
    yamlencode({
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = true
        }
      }
      machine = {
        registries = {
          mirrors = {
            "registry.k8s.io" = {
              endpoints    = ["http://10.0.1.50:5000"]
              skipFallback = true
            }
            "docker.io" = {
              endpoints    = ["http://10.0.1.50:5001"]
              skipFallback = true
            }
            "quay.io" = {
              endpoints    = ["http://10.0.1.50:5002"]
              skipFallback = true
            }
          }
        }
        install = {
          disk = "/dev/sda"
        }
        disks = [
          {
            device = "/dev/sdb"
            partitions = [
              {
                mountpoint = "/var/lib/longhorn"
              }
            ]
          }
        ]
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = local.masters # map master-нод
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ipv4_address

  config_patches = [
    yamlencode({
      machine = {
        network = {
          # hostname = each.key
          interfaces = [{
            interface = "eth0"
            addresses = ["${each.value.ipv4_address}/24"]
            routes = [{
              network = "0.0.0.0/0",
              gateway = var.gateway
            }]
          }]
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = local.workers
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ipv4_address

  config_patches = [
    yamlencode({
      machine = {
        network = {
          # hostname = each.key
          interfaces = [{
            interface = "eth0"
            addresses = ["${each.value.ipv4_address}/24"]
            routes = [{
              network = "0.0.0.0/0",
              gateway = var.gateway
            }]
          }]
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.first_master_ip
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.first_master_ip
}
