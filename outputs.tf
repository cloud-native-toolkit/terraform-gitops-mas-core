
output "name" {
  description = "The name of the module"
  value       = local.name
  depends_on  = [gitops_module.instance]
}

output "branch" {
  description = "The branch where the module config has been placed"
  value       = local.application_branch
  depends_on  = [gitops_module.instance]
}

output "namespace" {
  description = "The namespace where the module will be deployed"
  value       = local.namespace
  depends_on  = [gitops_module.instance]
}

output "server_name" {
  description = "The server where the module will be deployed"
  value       = var.server_name
  depends_on  = [gitops_module.instance]
}

output "layer" {
  description = "The layer where the module is deployed"
  value       = local.layer
  depends_on  = [gitops_module.instance]
}

output "type" {
  description = "The type of module where the module is deployed"
  value       = local.type
  depends_on  = [gitops_module.instance]
}

output "core_namespace" {
  description = "The namespace where the core instance has been deployed"
  value       = local.core_namespace
  depends_on = [gitops_module.instance]
}

output "entitlement_secret_name" {
  description = "The name of the secret that contains the entitlement_key"
  value       = local.secret_name
  depends_on  = [gitops_module.instance]
}

output "mas_instance_id" {
  description = "The identifier of the MAS instance that was created"
  value       = var.mas_instance_id
  depends_on  = [gitops_module.instance]
}

output "mas_workspace_id" {
  description = "The identifier of the MAS workspace that was created"
  value       = var.mas_workspace_id
  depends_on  = [gitops_module.instance]
}
