module "azuread_app_role_assignments" {
  source     = "./modules/azuread/azuread_app_role_assignments"
  for_each   = local.azuread.azuread_app_role_assignments

  resource_object_id      = can(each.value.resource_object.id) ? each.value.resource_object.id : local.combined_objects_azuread_service_principals[try(each.value.resource_object.lz_key, local.client_config.landingzone_key)][each.value.resource_object.key].object_id
  client_config           = local.client_config
  settings                = each.value
  azuread_groups          = local.combined_objects_azuread_groups
  azuread_users           = local.combined_objects_azuread_users
  azuread_service_principals  = local.combined_objects_azuread_service_principals
}

output "azuread_app_role_assignments" {
  value = module.azuread_app_role_assignments
}