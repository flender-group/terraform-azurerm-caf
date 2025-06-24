resource "azuread_group" "group" {

  administrative_unit_ids = can(var.azuread_dynamic_groups.administrative_unit_ids) || can(var.azuread_dynamic_groups.administrative_units) == false ? try(var.azuread_dynamic_groups.administrative_unit_ids, null) : local.administrative_unit_ids
  assignable_to_role      = try(var.azuread_dynamic_groups.assignable_to_role, null)
  display_name            = var.global_settings.passthrough || try(var.azuread_dynamic_groups.global_settings.passthrough, false) == true ? format("%s", local.display_name) : format("%s%s", try(format("%s-", var.global_settings.prefixes.0), ""), local.display_name)
  description             = lookup(var.azuread_dynamic_groups, "description", null)
  types                   = ["DynamicMembership"]
  prevent_duplicate_names = lookup(var.azuread_dynamic_groups, "prevent_duplicate_names", null)
  owners                  = length(local.owners) > 0 ? local.owners : null
  security_enabled  = try(var.azuread_dynamic_groups.security_enabled, true)
  visibility        = try(var.azuread_dynamic_groups.visibility, null)
  writeback_enabled = try(var.azuread_dynamic_groups.writeback_enabled, null)

  dynamic "dynamic_membership" {
    for_each = try(var.azuread_dynamic_groups.member_groups, null) == null ? [] : [var.azuread_dynamic_groups.member_groups]
    content {
      rule = "user.memberOf -any (group.objectId -in ${jsonencode(local.member_group_object_ids)})"
      enabled = dynamic_membership.value.enabled
    }
  }

  dynamic "dynamic_membership" {
    for_each = try(var.azuread_dynamic_groups.member_users, null) == null ? [] : [var.azuread_dynamic_groups.member_users]
    content {
      rule = "user.memberOf -any (group.objectId -in ${jsonencode(local.member_user_object_ids)})"
      enabled = dynamic_membership.value.enabled
    }
  }

  dynamic "dynamic_membership" {
    for_each = try(var.azuread_dynamic_groups.custom_rule, null) == null ? [] : [var.azuread_dynamic_groups.custom_rule]
    content {
      rule = dynamic_membership.value.custom_rule
      enabled = dynamic_membership.value.enabled
    }
  }

}
data "azuread_user" "main" {
  for_each            = try(toset(var.azuread_dynamic_groups.owners.user_principal_names), {})
  user_principal_name = each.value
}
data "azuread_user" "member_users" {
  for_each            = try(toset(var.azuread_dynamic_groups.member_users.user_principal_names), {})
  user_principal_name = each.value
}

locals {
  owners = concat(
    try(tolist(var.azuread_dynamic_groups.owners), []),
    local.ad_user_oids
  )
  ad_user_oids = [for user in try(var.azuread_dynamic_groups.owners.user_principal_names, []) :
    data.azuread_user.main[user].object_id
  ]

  display_name = can(var.azuread_dynamic_groups.display_name) ? var.azuread_dynamic_groups.display_name : var.azuread_dynamic_groups.name

  administrative_unit_ids = flatten(
    [
      for key, value in try(var.azuread_dynamic_groups.administrative_units, {}) : [
        can(value.id) ? value.id : var.remote_objects.azuread_administrative_units[try(value.lz_key, var.client_config.landingzone_key)][value.key].object_id
      ]
    ]
  )
  member_group_object_ids = [
    for group in try(var.azuread_dynamic_groups.member_groups.group_keys, []) : 
    var.remote_objects.azuread_groups[try(var.azuread_dynamic_groups.member_groups.lz_key, var.client_config.landingzone_key)][group].object_id
  ]
  member_user_object_ids = [
    for user in try(var.azuread_dynamic_groups.member_users.user_principal_names, []) :
    data.azuread_user.member_users[user].object_id
  ]
}

