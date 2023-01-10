# Maximo Application Suite Core gitops module

Module to populate a gitops repo with the resources to provision the MAS Auto Operator and create an instance of MAS Core.


## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v0.15

### Terraform providers

- Gitops provider >= 0.1.7
- Clis provider

## Module dependencies

This module makes use of the output from other modules:

- GitOps - github.com/cloud-native-toolkit/terraform-tools-gitops.git
- Namespace - github.com/cloud-native-toolkit/terraform-gitops-namespace.git

## Example usage

```hcl-terraform
module "mas_core" {
   source = "github.com/cloud-native-toolkit/terraform-gitops-mas-core.git"
   
   gitops_config = module.gitops.gitops_config
   git_credentials = module.gitops.git_credentials
   kubeseal_cert = module.gitops.sealed_secrets_cert
   server_name = module.gitops.server_name

   catalog_name = module.toolkit_catalog.name
   entitlement_key = var.cp_entitlement_key
   uds_contact_email = "someone@somewhere.com"
   uds_contact_first_name = "Test"
   uds_contact_last_name = "User"
   mongodb_storage_class = module.storage_manager.block_storage_class
   uds_storage_class = module.storage_manager.block_storage_class
}
```
