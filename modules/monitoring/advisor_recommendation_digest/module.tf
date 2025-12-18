resource "null_resource" "ard" {
  triggers = {
    subscription_id     = local.subscription_id
    action_group_id     = local.action_group_id
    low_cpu_threshold   = try(var.settings.low_cpu_threshold, "")
    duration            = try(var.settings.duration, "")
    exclude             = try(var.settings.exclude, false)
    frequency           = try(var.settings.frequency, 30)
    categories          = join(",", try(var.settings.categories, []))
    language            = try(var.settings.language, "en")
    state               = try(var.settings.state, "Active")
    digest_name         = try(var.settings.digest_name, "recommendation-digest")
    api_url             = local.api_url
    script_path         = local.script_path
  }

  provisioner "local-exec" {
    command     = "${local.script_path} update '${local.api_url}' '${local.payload}'"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "${self.triggers.script_path} delete '${self.triggers.api_url}'"
    interpreter = ["/bin/bash", "-c"]
  }
}