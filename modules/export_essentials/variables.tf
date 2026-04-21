variable "remote_objects" {
  description = "Map of remote objects to export"
  default     = {}
}
variable "settings" {
  description = "Settings for export essentials"
}
variable "client_config" {
  description = "Client configuration object"
}
variable "storage_accounts" {
  description = "Map of storage account remote objects"
  type = map(any)
  default = {}
}