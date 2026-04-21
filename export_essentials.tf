module "export_essentials" {
  for_each = try(var.export_essentials, {})
  source = "./modules/export_essentials"
  settings = var.export_essentials
  storage_accounts = local.combined_objects_storage_accounts
  remote_objects = {
    azuread_applications = module.azuread_applications_v1
    azuread_groups       = module.azuread_groups
    azuread_service_principals = module.azuread_service_principals
    credentials       = module.azuread_credentials
    vnets             = module.networking
    public_dns        = module.dns_zones
    private_dns       = module.private_dns
    managed_identities = module.managed_identities
    keyvaults           = module.keyvaults
    storage_accounts    = module.storage_accounts
  }
  client_config = local.client_config
}

