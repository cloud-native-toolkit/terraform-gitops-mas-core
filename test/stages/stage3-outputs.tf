
resource local_file write_outputs {
  filename = "gitops-output.json"

  content = jsonencode({
    name        = module.gitops_module.name
    branch      = module.gitops_module.branch
    namespace   = module.gitops_module.namespace
    server_name = module.gitops_module.server_name
    layer       = module.gitops_module.layer
    layer_dir   = module.gitops_module.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_module.layer == "services" ? "2-services" : "3-applications")
    type        = module.gitops_module.type

    core_namespace = module.gitops_module.core_namespace
    mas_instance_id = module.gitops_module.mas_instance_id
  })
}
