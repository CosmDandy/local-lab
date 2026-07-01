output "template_id" {
  description = "VM ID созданного шаблона — передаётся в clone модуля proxmox-vm"
  value       = proxmox_virtual_environment_vm.template.vm_id
}
