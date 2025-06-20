variable "settings" {
  default = {}
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "resource_object_id" {
  type = string
}
variable "azuread_groups" {}
variable "azuread_users" {}
variable "azuread_service_principals" {}
