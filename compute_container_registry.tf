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
  quarantine_policy_enabled = try(each.value.quarantine_policy_enabled, false)
  zone_redundancy_enabled   = try(each.value.zone_redundancy_enabled, false)
  export_policy_enabled     = try(each.value.export_policy_enabled, true)
  trust_policy              = try(each.value.trust_policy, {})
  retention_policy          = try(each.value.retention_policy, {})
}

output "azure_container_registries" {
  value = module.container_registry

}

