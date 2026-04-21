output "client_id_secret_name" {
  description = "The KV secret name of the Azure AD Application Client ID."
  value       = { for k, v in azurerm_key_vault_secret.client_id : k => v.name }
}
output "client_id_secret_id" {
  description = "The KV secret ID of the Azure AD Application Client ID."
  value = { for k, v in azurerm_key_vault_secret.client_id : k => v.id }
}
output "client_id_secret_versionless_id" {
  description = "The KV secret ID of the Azure AD Application Client ID."
  value = { for k, v in azurerm_key_vault_secret.client_id : k => v.versionless_id }
}
output "client_id_secret_key_vault_id" {
  description = "The KV secret ID of the Azure AD Application Client ID."
  value = { for k, v in azurerm_key_vault_secret.client_id : k => v.key_vault_id }
}
output "client_secret_secret_name" {
  description = "The KV secret name of the Azure AD Application Client Secret."
  value = { for k, v in azurerm_key_vault_secret.client_secret : k => v.name }
}
output "client_secret_secret_id" {
  description = "The KV secret ID of the Azure AD Application Client Secret."
  value = { for k, v in azurerm_key_vault_secret.client_secret : k => v.id }
}
output "client_secret_secret_versionless_id" {
  description = "The KV secret ID of the Azure AD Application Client Secret."
  value = { for k, v in azurerm_key_vault_secret.client_secret : k => v.versionless_id }
}
output "client_secret_secret_key_vault_id" {
  description = "The KV secret ID of the Azure AD Application Client Secret."
  value = { for k, v in azurerm_key_vault_secret.client_secret : k => v.key_vault_id }
}