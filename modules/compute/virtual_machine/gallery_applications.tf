resource "azurerm_virtual_machine_gallery_application_assignment" "vm" {
  for_each = var.settings.gallery_applications
  gallery_application_version_id = coalesce(
    try(var.gallery_application_versions[try(each.value.lz_key, var.client_config.landingzone_key)][try(each.value.version_key, null)].id, null), try(each.value.version_id, null)
    )
  virtual_machine_id             = local.os_type == "linux" ? azurerm_linux_virtual_machine.vm["linux"].id : azurerm_windows_virtual_machine.vm["windows"].id
  configuration_blob_uri         = try(each.value.configuration_blob_uri, null)
  order                          = try(each.value.order, null)
}