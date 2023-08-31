module "cognitive_services_account" {
  source   = "./modules/cognitive_services/cognitive_services_account"
  for_each = local.cognitive_services.cognitive_services_account

  client_config       = local.client_config
  global_settings     = local.global_settings
  base_tags           = local.global_settings.inherit_tags
  resource_group_name = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name
  location            = lookup(each.value, "region", null) == null ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location : local.global_settings.regions[each.value.region]
  settings            = each.value
  private_dns         = local.combined_objects_private_dns
  private_endpoints   = try(each.value.private_endpoints, {})
  vnets               = local.combined_objects_networking
  virtual_subnets     = local.combined_objects_virtual_subnets
}

output "cognitive_services_account" {
  value = module.cognitive_services_account
}
