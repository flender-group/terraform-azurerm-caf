resource "null_resource" "essentials" {
  triggers = {
    blob_name              = var.settings.storage_account.blob_name
    content_hash           = sha256(local.essentials_content)
    storage_account_name   = local.storage_account_name
    storage_container_name = var.settings.storage_account.container_name
    subscription_id        = local.subscription_id
  }

  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/upload_blob.sh upload"

    environment = {
      BLOB_CONTENT           = local.essentials_content
      BLOB_NAME              = self.triggers.blob_name
      STORAGE_ACCOUNT_NAME   = self.triggers.storage_account_name
      STORAGE_CONTAINER_NAME = self.triggers.storage_container_name
      SUBSCRIPTION_ID        = self.triggers.subscription_id
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "/bin/bash ${path.module}/upload_blob.sh delete"

    environment = {
      BLOB_NAME              = self.triggers.blob_name
      STORAGE_ACCOUNT_NAME   = self.triggers.storage_account_name
      STORAGE_CONTAINER_NAME = self.triggers.storage_container_name
      SUBSCRIPTION_ID        = self.triggers.subscription_id
    }
  }

  lifecycle {
    precondition {
      condition     = local.storage_account_name != null
      error_message = "export_essentials requires settings.storage_account.name or a resolvable storage account reference."
    }
  }
}