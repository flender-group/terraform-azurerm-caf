
resource "azuread_custom_directory_role" "directory_role" {
  //todo: implement CAF Name Resource
  display_name = var.settings.display_name
  description  = try(var.settings.description, "none")
  enabled      = var.settings.enabled
  version      = var.settings.version

  dynamic "permissions" {
    for_each = var.settings.permissions
    content {
      allowed_resource_actions = permissions.value
    }
  }
}

# Condition https://learn.microsoft.com/en-us/graph/api/resources/unifiedrolepermission?view=graph-rest-1.0