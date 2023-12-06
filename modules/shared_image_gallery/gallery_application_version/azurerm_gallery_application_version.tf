data "azurerm_storage_account" "installer" {
  count = can(var.settings.media_link) ? 0 : 1

  name                = local.installer_storage_account.name
  resource_group_name = local.installer_storage_account.resource_group_name
}

data "azurerm_storage_blob" "installer" {
  count = can(var.settings.media_link) ? 0 : 1
  name                   = var.settings.storage_accounts.blob_name
  storage_account_name   = local.installer_storage_account.name
  storage_container_name = local.installer_storage_account.containers[var.settings.storage_accounts.container_key].name
}

data "azurerm_storage_account_sas" "installer" {
  count = can(var.settings.media_link) ? 0 : 1

  connection_string = data.azurerm_storage_account.installer.0.primary_connection_string
  https_only        = true

  start  = time_rotating.sas[0].id
  expiry = timeadd(time_rotating.sas[0].id, format("%sh", var.settings.storage_accounts.sas_policy.expire_in_days * 24))

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read   = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

resource "time_rotating" "sas" {
  count = can(var.settings.storage_accounts.sas_policy) ? 1 : 0

  rotation_minutes = lookup(var.settings.storage_accounts.sas_policy.rotation, "mins", null)
  rotation_days    = lookup(var.settings.storage_accounts.sas_policy.rotation, "days", null)
  rotation_months  = lookup(var.settings.storage_accounts.sas_policy.rotation, "months", null)
  rotation_years   = lookup(var.settings.storage_accounts.sas_policy.rotation, "years", null)
}

resource "azurerm_gallery_application_version" "gallery_application_version" {
  name                   = var.settings.name
  gallery_application_id = var.gallery_application_id
  location               = var.location
  enable_health_check    = try(var.settings.enable_health_check, false)
  end_of_life_date       = try(var.settings.end_of_life_date, try(can(var.settings.media_link) ? null : timeadd(time_rotating.sas[0].id, format("%sh", var.settings.storage_accounts.sas_policy.expire_in_days * 24))))
  exclude_from_latest    = try(var.settings.exclude_from_latest, false)
  tags                   = local.tags
  manage_action {
    install = var.settings.install_cmd
    remove  = var.settings.remove_cmd
    update  = try(var.settings.update_cmd, null)
  }

  source {
    media_link                 = try(var.settings.media_link, local.blob_sas_url)
    default_configuration_link = try(var.settings.default_configuration_link, null)
  }

  target_region {
    name                   = var.location
    regional_replica_count = try(var.settings.defult_regional_replica_count, 1)
    storage_account_type   = try(var.settings.defult_storage_account_type, "Standard_LRS")
  }
  dynamic "target_region" {
    for_each = try(var.settings.target_regions, {})
    content {
      name                   = try(target_region.value.name, null)
      regional_replica_count = coalesce(try(target_region.value.regional_replica_count, null), try(var.settings.default_regional_replica_count, 1))
      storage_account_type   = coalesce(try(target_region.value.storage_account_type, null), try(var.settings.defult_storage_account_type, "Standard_LRS"))
    }
  }
}