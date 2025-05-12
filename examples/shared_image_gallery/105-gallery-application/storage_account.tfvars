storage_accounts = {
  installer = {
    name = "installer"
    resource_group_key = "gallery_app"
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "LRS"
    containers = {
      installer = {
        name = "installer"
      }
    }
    enable_system_msi = true
  }
}