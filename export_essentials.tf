module "export_essentials" {
  for_each = try(var.export_essentials, {})
  source = "./modules/export_essentials"
  settings = var.export_essentials
  storage_accounts = local.combined_objects_storage_accounts
  remote_objects = {
    azuread_application = module.azuread_applications_v1
    azuread_group       = module.azuread_groups
    azuread_service_principal = module.azuread_service_principals
    credentials       = module.azuread_credentials
    virtual_network = module.networking
    public_dns        = module.dns_zones
    private_dns       = module.private_dns
    user_assigned_identity  = module.managed_identities
    key_vault           = module.keyvaults
    storage_account    = module.storage_accounts
  }
  client_config = local.client_config
  depends_on = [
    module.storage_accounts
  ]
}

