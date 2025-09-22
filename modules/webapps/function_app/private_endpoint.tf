module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = {
    for k,v in var.private_endpoints : k => v if lookup(v, "ignore_private_dns_zone_group", false) == false
  }

  resource_id         = azurerm_function_app.function_app.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = can(each.value.subnet_id) || can(each.value.virtual_subnet_key) ? try(each.value.subnet_id, var.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.virtual_subnet_key].id) : var.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
  settings            = each.value
  global_settings     = var.global_settings
  tags                = local.tags
  base_tags           = var.base_tags
  private_dns         = var.private_dns
  client_config       = var.client_config
}

module "private_endpoint_v1" {
  source   = "../../networking/private_endpoint_v1"
  for_each = {
    for k,v in var.private_endpoints : k => v if lookup(v, "ignore_private_dns_zone_group", false) == true
  }

  resource_id         = azurerm_function_app.function_app.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = can(each.value.subnet_id) || can(each.value.virtual_subnet_key) ? try(each.value.subnet_id, var.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.virtual_subnet_key].id) : var.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
  settings            = each.value
  global_settings     = var.global_settings
  tags                = local.tags
  base_tags           = var.base_tags
  client_config       = var.client_config
}