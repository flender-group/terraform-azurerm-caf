module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_static_site.static_site.id
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = can(each.value.subnet_id) || can(each.value.virtual_subnet_key) ? try(each.value.subnet_id, var.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.virtual_subnet_key].id) : var.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
  settings            = each.value
  global_settings     = var.global_settings
  tags                = local.tags
  base_tags           = var.global_settings.inherit_tags
  private_dns         = var.private_dns
  client_config       = var.client_config
}
