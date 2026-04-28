output "blob_name" {
  description = "The name of the blob written to storage."
  value       = var.settings.storage_account.blob_name
}

output "storage_account_name" {
  description = "The storage account where the essentials blob was written."
  value       = local.storage_account_name
}

output "storage_container_name" {
  description = "The storage container where the essentials blob was written."
  value       = var.settings.storage_account.container_name
}

