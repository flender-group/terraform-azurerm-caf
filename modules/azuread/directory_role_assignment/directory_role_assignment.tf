#resource "azuread_directory_role_assignment" "directory_role_assignment" {
#  role_id             = azuread_custom_directory_role.example.object_id
#  principal_object_id = data.azuread_user.example.object_id
#}
#
resource "null_resource" "debug" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = jsonencode(local.custom_role_id)
  }
}
locals {
  custom_role_id = {for role, config in try(var.settings.custom_azuread_roles, {}) :
    role => var.remote_objects["azuread_custom_directory_roles"][try(config.lz_key, var.client_config.landingzone_key)][role].id
  }  
}
output "custom_role_id" {
  value = local.custom_role_id
}
