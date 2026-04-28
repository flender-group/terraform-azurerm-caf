locals {
  storage_account = try(
    var.storage_accounts[try(
      var.settings.storage_account.lz_key, var.client_config.landingzone_key
      )][var.settings.storage_account.key],
    {}
  )

  storage_account_name = coalesce(
    try(local.storage_account.name, null),
    try(var.settings.storage_account.name, null)
  )

  subscription_id = coalesce(
    try(split("/", local.storage_account.id)[2], null),
    try(var.settings.storage_account.subscription_id, null),
    var.client_config.subscription_id
  )

  essentials_content        = jsonencode(local.json_data)
}
