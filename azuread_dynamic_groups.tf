
#
# Azure Active Directory Dynamic Groups
#

module "azuread_dynamic_groups" {
  source   = "./modules/azuread/dynamic_groups"
  for_each = local.azuread.azuread_dynamic_groups

  global_settings        = local.global_settings
  azuread_dynamic_groups = each.value
  tenant_id              = local.client_config.tenant_id
  client_config          = local.client_config
  remote_objects = {
    azuread_administrative_units = local.combined_objects_azuread_administrative_units
    azuread_groups               = local.combined_objects_azuread_groups
  }
}

output "azuread_dynamic_groups" {
  value = module.azuread_dynamic_groups
}