locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    local.module_tag,
    try(var.settings.tags, null)
    ) : merge(
    local.module_tag,
    try(var.settings.tags,
    null)
  )

  installer_storage_account = can(var.settings.media_link) ? null : var.storage_accounts[try(var.settings.storage_accounts.lz_key, var.client_config.landingzone_key)][var.settings.storage_accounts.storage_account_key]
  blob_sas_url = can(var.settings.media_link) ? null : "${data.azurerm_storage_blob.installer[0].url}${data.azurerm_storage_account_sas.installer[0].sas}"
}