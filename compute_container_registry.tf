module "container_registry" {
  source   = "./modules/compute/container_registry"
  for_each = local.compute.azure_container_registries

  global_settings     = local.global_settings
  client_config       = local.client_config
  name                = each.value.name
  admin_enabled       = try(each.value.admin_enabled, false)
  sku                 = try(each.value.sku, "Basic")
  tags                = try(each.value.tags, {})
  network_rule_set    = try(each.value.network_rule_set, {})
  vnets               = local.combined_objects_networking
  georeplications     = try(each.value.georeplications, {})
  diagnostics         = local.combined_diagnostics
  diagnostic_profiles = try(each.value.diagnostic_profiles, {})
  private_endpoints   = try(each.value.private_endpoints, {})
  private_dns         = local.combined_objects_private_dns
  resource_groups     = local.combined_objects_resource_groups
  settings            = each.value

  public_network_access_enabled = try(each.value.public_network_access_enabled, "true")
  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : null
  location            = try(local.global_settings.regions[each.value.region], null)
}

output "azure_container_registries" {
  value = module.container_registry

}

