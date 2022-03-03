output "kube_config" {
  value     = module.actions-runner-aks.kube_config
  sensitive = true
}

output "kube_config_raw" {
  value     = module.actions-runner-aks.kube_config_raw
  sensitive = true
}
