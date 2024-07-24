//testcase
locals {
  azuread_custom_directory_roles = {
    group_self_service = { // role key
      display_name = "group-self-service"
      description = "room for notes"
      enabled      = "true"
      version      = "1.0"
      permissions = {
        allowed_resource_actions =        [
          "microsoft.directory/groups/allProperties/read",
          "microsoft.directory/groups/members/read",
          "microsoft.directory/groups.security/createAsOwner",
          "microsoft.directory/groups/delete",
          "microsoft.directory/groups.security/allProperties/update",
          "microsoft.directory/groups/members/update"
        ]
      #[
      #  "microsoft.directory/applications/basic/update",
      #  "microsoft.directory/applications/create",
      #  "microsoft.directory/applications/standard/read",
      #]


      }
    }
  }
  azuread_directory_role_assignments = {
    custom_azuread_roles = {
      group_self_service = {
        //lz_key = ""
        azuread_groups = {
          keys = ["caf_group_self_service"]
          //lz_key = ""
        }
      }
    }
  }
}

module "azuread_custom_directory_roles" {
  source   = "./modules/azuread/custom_directory_roles"
  for_each = local.azuread_custom_directory_roles

  global_settings = local.global_settings
  tenant_id       = local.client_config.tenant_id
  client_config   = local.client_config
  settings      = each.value
}

output "azuread_custom_directory_roles" {
  value = module.azuread_custom_directory_roles
}


module "azuread_directory_role_assignments" {
  source   = "./modules/azuread/directory_role_assignment"
  for_each = local.azuread_directory_role_assignments

  global_settings = local.global_settings
  tenant_id       = local.client_config.tenant_id
  client_config   = local.client_config
  remote_objects = {
    azuread_custom_directory_roles = local.combined_objects_azuread_custom_directory_roles
    azuread_groups = local.combined_objects_azuread_groups
    azuread_apps = local.combined_objects_azuread_apps
  }
  settings      = each.value
}
output "azuread_directory_role_assignments" {
  value = module.azuread_directory_role_assignments
}