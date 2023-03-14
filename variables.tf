
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "catalog_name" {
  type        = string
  description = "The name of the catalog from which the masauto-operator can be installed"
  default     = "ecosystem-engineering-catalog"
}

variable "entitlement_key" {
  type        = string
  description = "The entitlement key used to access the Maximo Application Suite images in the container registry. Visit https://myibm.ibm.com/products-services/containerlibrary to get the key"
  sensitive   = true
}

variable "mas_channel" {
  type        = string
  description = "The name of the channel where the container images should be pulled (e.g. 8.8.x)"
  default     = "8.8.x"
}

variable "mas_instance_id" {
  type        = string
  description = "The identifier for the MAS instance"
  default     = "inst1"
}

variable "mas_workspace_id" {
  type        = string
  description = "The identifier for the workspace that will be created within the MAS instance"
  default     = "masdev"
}

variable "mas_workspace_name" {
  type        = string
  description = "The name of the workspace that will be created within the MAS instance"
  default     = "MAS Development"
}

variable "mongodb_storage_class" {
  type        = string
  description = "The storage class that should be used to provision storage for the MongoDB instance"
}

variable "uds_storage_class" {
  type        = string
  description = "The storage class that should be used to provision storage for the UDS instance"
}

variable "uds_contact_email" {
  type        = string
  description = "The email address of the contact person for UDS"
}

variable "uds_contact_first_name" {
  type        = string
  description = "The first name of the contact person for UDS"
}

variable "uds_contact_last_name" {
  type        = string
  description = "The last name of the contact person for UDS"
}

variable "host_id" {
  type        = string
  description = "The host id for the MAS core instance that is included in the license. If none is provided the host id will be generated."
  default     = ""
}

variable "license_key" {
  type        = string
  description = "The contents of the license key that should be applied to the new instance. The value can be provided directly or via the 'license_key_file' variable. If none is provided the license will need to be applied manually after install."
  default     = ""
}

variable "license_key_file" {
  type        = string
  description = "The name of the file containing the license key that should be applied to the new instance. The value can be provided in a file or directly via the 'license_key' variable. If none is provided the license will need to be applied manually after install."
  default     = ""
}

