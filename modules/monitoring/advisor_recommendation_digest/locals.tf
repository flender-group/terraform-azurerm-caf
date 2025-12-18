locals {
  subscription_id = var.client_config.subscription_id
  
  action_group_id = coalesce(
    try(var.remote_objects["monitor_action_groups"][var.settings.action_group.lz_key][var.settings.action_group.key].id, null),
    try(var.remote_objects["monitor_action_groups"][var.client_config.landingzone_key][var.settings.action_group.key].id, null),
    try(var.settings.action_group.id, null),
  )
  
  api_url = "https://management.azure.com/subscriptions/${local.subscription_id}/providers/Microsoft.Advisor/configurations/default?api-version=2025-01-01"
  
  payload = jsonencode({
    properties = {
      lowCpuThreshold = try(var.settings.low_cpu_threshold, null)
      duration        = try(var.settings.duration, null)
      exclude         = try(var.settings.exclude, false)
      digests = [
        {
          name                  = try(var.settings.digest_name, "recommendation-digest")
          actionGroupResourceId = local.action_group_id
          frequency             = try(var.settings.frequency, 30)
          categories            = try(var.settings.categories, ["HighAvailability", "Security", "Performance", "Cost", "OperationalExcellence"])
          language              = try(var.settings.language, "en")
          state                 = try(var.settings.state, "Active")
        }
      ]
    }
  })

  script_path = "${path.module}/scripts/advisor_config.sh"
}