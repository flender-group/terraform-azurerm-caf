variable "client_config" {}
variable "global_settings" {}
variable "settings" {}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "gallery_application_id" {}
variable "storage_accounts" {}
variable "location" {}