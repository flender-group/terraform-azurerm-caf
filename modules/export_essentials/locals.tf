locals {
  azuread_application_outputs = [
    "application_id",
    "object_id",
    "display_name"
  ]
  azuread_groups_outputs = [
    "object_id",
    "display_name"
  ]
  azuread_service_principals_outputs = [
    "application_id",
    "object_id",
    "rbac_id",
    "display_name"
  ]
  keyvaults_outputs = [
    "id",
    "name",
    "vault_uri"
  ]
  storage_accounts_outputs = [
    "id",
    "name",
    "primary_blob_endpoint"
  ]
  vnets_outputs = [
    "id",
    "name",
    "address_space",
    "subnets"
  ]
  public_dns_outputs = [
    "id",
    "name",
    "resource_group_name"
  ]
  private_dns_outputs = [
    "id",
    "name",
    "resource_group_name"
  ]
  credentials_outputs = [
    "client_secret_secret_name",
    "client_secret_secret_versionless_id",
    "client_secret_secret_key_vault_id",
    "client_id_secret_name",
    "client_id_secret_versionless_id",
    "client_id_secret_key_vault_id"
  ]
  managed_identity_outputs = [
    "principal_id",
    "client_id",
    "id",
    "name",
    "rbac_id"
  ]
  subnet_outputs = [
    "cidr",
    "name",
    "id"
  ]
}

locals {
  outputs = {
    azuread_applications = {
      for key, value in try(var.remote_objects.azuread_applications, {}) : key => {
        for output_key in local.azuread_application_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
    azuread_groups       = {
      for key, value in try(var.remote_objects.azuread_groups, {}) : key => {
        for output_key in local.azuread_groups_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
    azuread_service_principals = {
      for key, value in try(var.remote_objects.azuread_service_principals, {}) : key => {
        for output_key in local.azuread_service_principals_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
    keyvaults           = {
      for key, value in try(var.remote_objects.keyvaults, {}) : key => {
        for output_key in local.keyvaults_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
    storage_accounts    = {   
      for key, value in try(var.remote_objects.storage_accounts, {}) : key => {
        for output_key in local.storage_accounts_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
    vnets               = {
      for key, value in try(var.remote_objects.vnets, {}) : value["name"] => merge(
        {
          for output_key in local.vnets_outputs : output_key => value[output_key] if can(value[output_key]) && output_key != "subnets"
        },
        {
          subnets = {
            for subnet_key, subnet_value in try(value["subnets"], {}) : subnet_value["name"] => {
              for output_key in local.subnet_outputs : output_key => subnet_value[output_key] if can(subnet_value[output_key])
            }
          }
        }
      )
    }
    public_dns          = {
      for key, value in try(var.remote_objects.public_dns, {}) : value["name"] => {
        for output_key in local.public_dns_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
    private_dns         = { 
      for key, value in try(var.remote_objects.private_dns, {}) : value["name"] => {
        for output_key in local.private_dns_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
    credentials         = {
      for key, value in try(var.remote_objects.credentials, {}) : key => {
        for output_key in local.credentials_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
    managed_identities = {
      for key, value in try(var.remote_objects.managed_identities, {}) : key => {
        for output_key in local.managed_identity_outputs : output_key => value[output_key] if can(value[output_key])
      }
    }
  }
}