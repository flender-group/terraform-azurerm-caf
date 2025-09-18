resource "azurerm_virtual_hub_routing_intent" "this" {
  for_each       = local.networking.virtual_hub_routing_intents
  name           = each.value.name
  virtual_hub_id = can(each.value.virtual_hub_id) || can(each.value.virtual_hub.id) || can(each.value.vhub.virtual_wan_key) || can(each.value.virtual_wan_key) ? try(each.value.virtual_hub_id, each.value.virtual_hub.id, local.combined_objects_virtual_wans[try(each.value.vhub.lz_key, local.client_config.landingzone_key)][each.value.vhub.virtual_wan_key].virtual_hubs[each.value.vhub.virtual_hub_key].id, local.combined_objects_virtual_wans[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.virtual_wan_key].virtual_hubs[each.value.virtual_hub_key].id) : local.combined_objects_virtual_hubs[try(each.value.virtual_hub.lz_key, local.client_config.landingzone_key)][each.value.virtual_hub.key].id

  dynamic "routing_policy" {
    for_each = each.value.routing_policy
    content {
      name         = routing_policy.value.name
      destinations = routing_policy.value.destinations
      next_hop = coalesce(
        try(routing_policy.value.next_hop.id, routing_policy.value.next_hop_id, null),
        try(local.combined_objects_azurerm_firewalls[try(routing_policy.value.next_hop.lz_key, local.client_config.landingzone_key)][routing_policy.value.next_hop.firewall_key].id, null),
        try(local.combined_objects_virtual_wans[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.virtual_wan_key].virtual_hubs[routing_policy.value.next_hop.virtual_hub_key].security_partner_provider[routing_policy.value.next_hop.security_partner_provider_key].id, null),
        try(local.combined_objects_virtual_hubs[try(each.value.virtual_hub.lz_key, local.client_config.landingzone_key)][each.value.virtual_hub.key].security_partner_provider[routing_policy.value.next_hop.security_partner_provider_key].id, null)
      )
    }
  }
}