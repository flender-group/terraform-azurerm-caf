# Tested with :  AzureRM version 2.61.0
# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container

resource "azurerm_storage_container" "stg" {
  name                  = var.settings.name
  storage_account_name  = var.storage_account_name
  container_access_type = try(var.settings.container_access_type, "private")
  metadata              = try(var.settings.metadata, null)
}

resource "azurerm_storage_container_immutability_policy" "stg" {
  count                                 = try(var.settings.immutability_policy, null) == null ? 0 : 1
  storage_container_resource_manager_id = azurerm_storage_container.stg.resource_manager_id
  immutability_period_in_days           = var.settings.immutability_policy.immutability_period_in_days
  locked                                = try(var.settings.immutability_policy.locked, null)
  protected_append_writes_all_enabled   = try(var.settings.immutability_policy.protected_append_writes_all_enabled, null)
  protected_append_writes_enabled       = try(var.settings.immutability_policy.protected_append_writes_enabled, null)
}