resource "azuread_app_role_assignment" "app" {
  app_role_id         = var.settings.app_role_id
  resource_object_id  = var.resource_object_id
  principal_object_id = coalesce(
    try(var.azuread_users[try(var.settings.azuread_user.lz_key, var.client_config.landingzone_key)][var.settings.azuread_user.key].object_id, null),
    try(var.azuread_groups[try(var.settings.azuread_group.lz_key, var.client_config.landingzone_key)][var.settings.azuread_group.key].object_id, null),
    try(var.azuread_service_principals[try(var.settings.azuread_service_principal.lz_key, var.client_config.landingzone_key)][var.settings.azuread_service_principal.key].object_id, null),
    var.settings.object_id
  )
}