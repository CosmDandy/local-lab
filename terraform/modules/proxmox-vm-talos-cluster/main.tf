locals {
  masters         = { for k, v in var.vms : k => v if v.role == "controlplane" }
  workers         = { for k, v in var.vms : k => v if v.role == "worker" }
  first_master_ip = local.masters[keys(local.masters)[0]].ipv4_address

  gateway_crd_dir = "${path.module}/bootstrap/gateway-api-crds"
  os_datastore_id = "local-zfs"
  tags            = ["k8s", "terraform"]
  talos_image_url = "https://factory.talos.dev/image/${var.talos_schematic_id}/${var.talos_version}/nocloud-amd64.raw.gz"
  vm_id           = tonumber(format("%d%03d", tonumber(split(".", split("/", each.value.ipv4_address)[0])[2]), tonumber(split(".", split("/", each.value.ipv4_address)[0])[3])))
}

resource "proxmox_download_file" "talos" {
  content_type            = "iso"
  datastore_id            = var.image_datastore
  node_name               = var.proxmox_node_name
  url                     = local.talos_image_url
  file_name               = "talos-${var.talos_version}-nocloud-amd64.img"
  decompression_algorithm = "gz"

  # bpg на каждом plan сверяет размер по URL (сжатый .raw.gz) с сохранённым
  # (распакованным) → они не сходятся, size уходит в "known after apply" и ложно
  # форсит replace образа (каскадом — всех VM). overwrite=false: не перекачивать
  # существующий файл, тем самым убрать ложный replace. Реального дрейфа нет.
  overwrite = false
}

module "node" {
  source = "../../../modules/proxmox-vm-talos"

  for_each          = var.vms
  vm_name           = each.key
  vm_id             = locals.vm_id
  proxmox_node_name = var.proxmox_node_name
  os_datastore_id   = local.os_datastore_id
  image_file_id     = proxmox_download_file.talos.id
  tags              = local.tags
  cores             = each.value.cores
  memory            = each.value.memory
  disk_size         = each.value.disk_size
  ipv4_cidr         = "${each.value.ipv4_address}/24"
  gateway           = var.gateway
  data_disks        = each.value.data_disks
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
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
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${local.first_master_ip}:6443" # IP первой master
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = "v1.13" # задай явно — рекомендуется

  config_patches = var.each_controlplane_config_patches
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = "https://${local.first_master_ip}:6443" # IP первой master
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = "v1.13"

  config_patches = var.each_worker_config_patches
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = local.masters # map master-нод
  depends_on                  = [module.node]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ipv4_address

  config_patches = var.general_controlplane_config_patches
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = local.workers
  depends_on                  = [module.node]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ipv4_address

  config_patches = var.general_worker_config_patches
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

resource "local_sensitive_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = local.kubeconfig_path
  file_permission = "0600"
}

resource "local_sensitive_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = local.talosconfig_path
  file_permission = "0600"
}

