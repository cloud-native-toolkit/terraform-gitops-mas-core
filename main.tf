locals {
  name              = "mas-core"
  tmp_dir           = "${path.cwd}/.tmp/${local.name}"
  secret_dir        = "${local.tmp_dir}/secrets"
  operator_yaml_dir = "${local.tmp_dir}/chart/masauto-operator"
  instance_yaml_dir = "${local.tmp_dir}/chart/${local.name}"

  license_secret_name = "sls-bootstrap"
  license_content = var.license_key_file != "" ? file(var.license_key_file) : var.license_key
  service_account_name = "mas-core-license-job"
  sls_namespace = "ibm-sls"

  channel = "alpha"
  operator_values_content = {
    channel = local.channel
    catalogName = var.catalog_name
    catalogNamespace = "openshift-marketplace"
  }
  instance_values_content = {
    mas_channel: var.mas_channel
    entitlement_key_secret = local.secret_name
    mas_instance_id = var.mas_instance_id
    mas_workspace_id = var.mas_workspace_id
    mas_workspace_name = var.mas_workspace_name
    mongodb_storage_class = var.mongodb_storage_class
    uds_storage_class = var.uds_storage_class
    uds_contact_email = var.uds_contact_email
    uds_contact_first_name = var.uds_contact_first_name
    uds_contact_last_name = var.uds_contact_last_name

    targetNamespace = local.sls_namespace
    serviceAccount = {
      name = local.service_account_name
      create = false
      annotations = {}
    }
    image = {
      imageName = "quay.io/cloudnativetoolkit/cli-tools-core"
      imageTag = "v1.1-v1.6.1"
    }
    secretName = local.license_content != "" ? local.license_secret_name : ""
  }

  secret_name = "ibm-entitlement-key"
  layer = "services"
  type  = "instances"
  application_branch = "main"
  namespace = "masauto-operator-system"
  layer_config = var.gitops_config[local.layer]

  core_namespace = "mas-${var.mas_instance_id}-core"
}

resource gitops_namespace ns {

  name = local.namespace
  create_operator_group = true
  server_name = var.server_name
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}


resource gitops_namespace sls_ns {
  count = local.license_content != "" ? 1 : 0

  name = local.sls_namespace
  create_operator_group = true
  server_name = var.server_name
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

resource null_resource create_operator_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh 'masauto-operator' '${local.operator_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.operator_values_content)
    }
  }
}

resource gitops_module operator {
  depends_on = [null_resource.create_operator_yaml]

  name = "masauto-operator"
  content_dir = local.operator_yaml_dir
  type = "operators"
  namespace = gitops_namespace.ns.name
  server_name = var.server_name
  layer = local.layer
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

data clis_check clis {
  clis = ["kubectl"]
}

resource null_resource create_entitlement_secret {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-secret.sh ${local.secret_name} ${gitops_namespace.ns.name} cp ${local.secret_dir}"

    environment = {
      BIN_DIR = data.clis_check.clis.bin_dir
      PASSWORD = var.entitlement_key
    }
  }
}

resource null_resource create_license_secret {
  count = local.license_content != "" ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-license-secret.sh ${local.license_secret_name} ${gitops_namespace.ns.name} '${var.host_id}' '${local.secret_dir}'"

    environment = {
      BIN_DIR = data.clis_check.clis.bin_dir
      LICENSE_KEY = local.license_content
    }
  }
}

resource gitops_service_account job_sa {
  count = local.license_content != "" ? 1 : 0

  name = local.service_account_name
  namespace = gitops_namespace.ns.name
  server_name = var.server_name
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
  cluster_scope = true
  rules {
    api_groups = [""]
    resources = ["secrets","configmaps","namespaces"]
    verbs = ["*"]
  }
  rules {
    api_groups = ["project.openshift.io"]
    resources = ["projects"]
    verbs = ["*"]
  }
}

resource null_resource create_instance_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.instance_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.instance_values_content)
    }
  }
}

resource gitops_seal_secrets secret {
  depends_on = [null_resource.create_entitlement_secret, null_resource.create_license_secret, null_resource.create_instance_yaml]

  source_dir    = local.secret_dir
  dest_dir      = "${local.instance_yaml_dir}/templates"
  kubeseal_cert = var.kubeseal_cert
  tmp_dir       = local.tmp_dir
  annotations   = ["argocd.argoproj.io/sync-wave=-10"]
}


resource gitops_module instance {
  depends_on = [gitops_seal_secrets.secret, gitops_module.operator, null_resource.create_instance_yaml, gitops_service_account.job_sa]

  name = local.name
  namespace = gitops_namespace.ns.name
  content_dir = local.instance_yaml_dir
  server_name = var.server_name
  layer = local.layer
  type = local.type
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
