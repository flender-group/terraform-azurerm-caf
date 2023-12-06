resource "azurerm_gallery_application" "gallery_application" {
  name                  = var.settings.name
  gallery_id            = var.gallery_id
  location              = var.location
  supported_os_type     = var.settings.supported_os_type
  description           = try(var.settings.description, null)
  end_of_life_date      = try(var.settings.end_of_life_date, null)
  eula                  = try(var.settings.eula, null)
  privacy_statement_uri = try(var.settings.privacy_statement_uri, null)
  release_note_uri      = try(var.settings.release_note_uri, null)
  tags                  = local.tags
}