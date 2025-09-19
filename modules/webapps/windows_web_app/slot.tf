# Per options https://www.terraform.io/docs/providers/azurerm/r/app_service.html

resource "azurerm_windows_web_app_slot" "slots" {
  for_each = var.slots

  name           = each.value.name
  app_service_id = azurerm_windows_web_app.app_service.id
  tags           = local.tags

  client_affinity_enabled = lookup(each.value, "client_affinity_enabled", null)
  enabled                 = lookup(each.value, "enabled", null)
  https_only              = lookup(each.value, "https_only", null)

  dynamic "identity" {
    for_each = try(var.identity, null) != null ? [1] : []

    content {
      type         = try(var.identity.type, null)
      identity_ids = lower(var.identity.type) == "userassigned" ? local.managed_identities : null
    }
  }

  key_vault_reference_identity_id = can(each.value.key_vault_reference_identity.key) ? var.combined_objects.managed_identities[try(each.value.key_vault_reference_identity.lz_key, var.client_config.landingzone_key)][each.value.key_vault_reference_identity.key].id : try(each.value.key_vault_reference_identity.id, null)

  site_config {
    always_on                         = lookup(each.value.site_config, "always_on", null)
    app_command_line                  = lookup(each.value.site_config, "app_command_line", null)
    auto_heal_enabled                 = lookup(each.value.site_config, "auto_heal_enabled", null)
    default_documents                 = lookup(each.value.site_config, "default_documents", null)
    ftps_state                        = lookup(each.value.site_config, "ftps_state", "FtpsOnly")
    health_check_path                 = lookup(each.value.site_config, "health_check_path", null)
    health_check_eviction_time_in_min = lookup(each.value.site_config, "health_check_eviction_time_in_min", null)
    http2_enabled                     = lookup(each.value.site_config, "http2_enabled", null)
    load_balancing_mode               = lookup(each.value.site_config, "load_balancing_mode", null)
    local_mysql_enabled               = lookup(each.value.site_config, "local_mysql_enabled", null)
    managed_pipeline_mode             = lookup(each.value.site_config, "managed_pipeline_mode", null)
    minimum_tls_version               = lookup(each.value.site_config, "minimum_tls_version", null)
    windows_fx_version                = lookup(each.value.site_config, "windows_fx_version", null)
    remote_debugging_enabled          = lookup(each.value.site_config, "remote_debugging_enabled", null)
    remote_debugging_version          = lookup(each.value.site_config, "remote_debugging_version", null)
    use_32_bit_worker                 = lookup(each.value.site_config, "use_32_bit_worker", null)
    vnet_route_all_enabled            = lookup(each.value.site_config, "vnet_route_all_enabled", null)
    websockets_enabled                = lookup(each.value.site_config, "websockets_enabled", null)
    worker_count                      = lookup(each.value.site_config, "worker_count", null)
    scm_type                          = lookup(each.value.site_config, "scm_type", null)

    dynamic "auto_heal_setting" {
      for_each = lookup(each.value, "auto_heal_setting", {}) != {} ? [1] : []

      content {
        action {
          action_type                    = auto_heal_setting.value.action.action_type
          minimum_process_execution_time = try(auto_heal_setting.value.action.minimum_process_execution_time, null)
        }
        trigger {
          private_memory_kb = try(auto_heal_setting.value.trigger.private_memory_kb, null)

          dynamic "requests" {
            for_each = lookup(auto_heal_setting.value.trigger, "requests", {}) != {} ? [1] : []

            content {
              count    = auto_heal_setting.value.trigger.requests.count
              interval = auto_heal_setting.value.trigger.requests.interval
            }
          }
          dynamic "slow_request" {
            for_each = auto_heal_setting.value.trigger.slow_request

            content {
              count      = slow_request.value.count
              interval   = slow_request.value.interval
              time_taken = slow_request.value.time_taken
            }
          }
          dynamic "slow_request_with_path" {
            for_each = try(auto_heal_setting.value.trigger.slow_request_with_path, {})

            content {
              count      = slow_request_with_path.value.count
              interval   = slow_request_with_path.value.interval
              time_taken = slow_request_with_path.value.time_taken
              path       = try(slow_request_with_path.value.path, null)
            }
          }
          dynamic "status_code" {
            for_each = try(auto_heal_setting.value.trigger.status_code, {})

            content {
              count             = status_code.value.count
              interval          = status_code.value.interval
              status_code_range = status_code.value.status_code_range
              path              = try(status_code.value.path, null)
              sub_status        = try(status_code.value.sub_status, null)
              win32_status_code = try(status_code.value.win32_status_code, null)
            }
          }
        }
      }
    }

    application_stack {
      docker_image_name        = try(each.value.site_config.application_stack.docker_image_name, null)
      docker_registry_url      = try(each.value.site_config.application_stack.docker_registry_url, null)
      docker_registry_username = try(each.value.site_config.application_stack.docker_registry_username, null)
      docker_registry_password = try(each.value.site_config.application_stack.docker_registry_password, null)
      python_version           = try(each.value.site_config.application_stack.python_version, null)
      node_version             = try(each.value.site_config.application_stack.node_version, null)
      php_version              = try(each.value.site_config.application_stack.php_version, null)
      dotnet_version           = try(each.value.site_config.application_stack.dotnet_version, null)
      dotnet_core_version      = try(each.value.site_config.application_stack.dotnet_core_version, null)
      tomcat_version           = try(each.value.site_config.application_stack.tomcat_version, null)
      java_version             = try(each.value.site_config.application_stack.java_version, null)
      java_container           = try(each.value.site_config.application_stack.java_container, null)
      java_container_version   = try(each.value.site_config.application_stack.java_container_version, null)
      python                   = try(each.value.site_config.application_stack.python, null)
    }

    dynamic "cors" {
      for_each = lookup(each.value.site_config, "cors", {}) != {} ? [1] : []

      content {
        allowed_origins     = lookup(each.value.site_config.cors, "allowed_origins", null)
        support_credentials = lookup(each.value.site_config.cors, "support_credentials", null)
      }
    }
    dynamic "ip_restriction" {
      for_each = lookup(each.value.site_config, "ip_restriction", {})

      content {
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
      }
    }
    dynamic "scm_ip_restriction" {
      for_each = try(each.value.site_config.scm_ip_restriction, {})

      content {
        ip_address                = lookup(scm_ip_restriction.value, "ip_address", null)
        service_tag               = lookup(scm_ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = can(scm_ip_restriction.value.virtual_network_subnet_id) ? scm_ip_restriction.value.virtual_network_subnet_id : can(scm_ip_restriction.value.virtual_network_subnet.id) ? scm_ip_restriction.value.virtual_network_subnet.id : can(scm_ip_restriction.value.virtual_network_subnet.subnet_key) ? var.combined_objects.networking[try(scm_ip_restriction.value.virtual_network_subnet.lz_key, var.client_config.landingzone_key)][scm_ip_restriction.value.virtual_network_subnet.vnet_key].subnets[scm_ip_restriction.value.virtual_network_subnet.subnet_key].id : null
        name                      = lookup(scm_ip_restriction.value, "name", null)
        priority                  = lookup(scm_ip_restriction.value, "priority", null)
        action                    = lookup(scm_ip_restriction.value, "action", null)
        dynamic "headers" {
          for_each = try(scm_ip_restriction.headers, {})

          content {
            x_azure_fdid      = lookup(headers.value, "x_azure_fdid", null)
            x_fd_health_probe = lookup(headers.value, "x_fd_health_probe", null)
            x_forwarded_for   = lookup(headers.value, "x_forwarded_for", null)
            x_forwarded_host  = lookup(headers.value, "x_forwarded_host", null)
          }
        }
      }
    }

    dynamic "virtual_application" {
      for_each = try(each.value.site_config.virtual_application, {})
      content {
        physical_path = virtual_application.value.physical_path
        virtual_path  = virtual_application.value.virtual_path
        preload       = virtual_application.value.preload

        dynamic "virtual_directory" {
          for_each = try(virtual_application.value.virtual_directory, {})
          content {
            physical_path = virtual_directory.value.physical_path
            virtual_path  = virtual_directory.value.virtual_path
          }

        }
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "auth_settings" {
    for_each = lookup(each.value, "auth_settings", {}) != {} ? [1] : []

    content {
      enabled                        = lookup(each.value.auth_settings, "enabled", null)
      allowed_external_redirect_urls = lookup(each.value.auth_settings, "allowed_external_redirect_urls", null)
      issuer                         = lookup(each.value.auth_settings, "issuer", null)
      runtime_version                = lookup(each.value.auth_settings, "runtime_version", null)
      token_refresh_extension_hours  = lookup(each.value.auth_settings, "token_refresh_extension_hours", null)
      token_store_enabled            = lookup(each.value.auth_settings, "token_store_enabled", null)
      unauthenticated_client_action  = lookup(each.value.auth_settings, "unauthenticated_client_action", null)

      dynamic "active_directory" {
        for_each = lookup(each.value.auth_settings, "active_directory", {}) != {} ? [1] : []

        content {
          client_id         = each.value.auth_settings.active_directory.client_id
          client_secret     = lookup(each.value.auth_settings.active_directory, "client_secret", null)
          allowed_audiences = lookup(each.value.auth_settings.active_directory, "allowed_audiences", null)
        }
      }

      dynamic "facebook" {
        for_each = lookup(each.value.auth_settings, "facebook", {}) != {} ? [1] : []

        content {
          app_id       = each.value.auth_settings.facebook.app_id
          app_secret   = each.value.auth_settings.facebook.app_secret
          oauth_scopes = lookup(each.value.auth_settings.facebook, "oauth_scopes", null)
        }
      }

      dynamic "google" {
        for_each = lookup(each.value.auth_settings, "google", {}) != {} ? [1] : []

        content {
          client_id     = each.value.auth_settings.google.client_id
          client_secret = each.value.auth_settings.google.client_secret
          oauth_scopes  = lookup(each.value.auth_settings.google, "oauth_scopes", null)
        }
      }

      dynamic "microsoft" {
        for_each = lookup(each.value.auth_settings, "microsoft", {}) != {} ? [1] : []

        content {
          client_id     = each.value.auth_settings.microsoft.client_id
          client_secret = each.value.auth_settings.microsoft.client_secret
          oauth_scopes  = lookup(each.value.auth_settings.microsoft, "oauth_scopes", null)
        }
      }

      dynamic "twitter" {
        for_each = lookup(each.value.auth_settings, "twitter", {}) != {} ? [1] : []

        content {
          consumer_key    = each.value.auth_settings.twitter.consumer_key
          consumer_secret = each.value.auth_settings.twitter.consumer_secret
        }
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = lookup(each.value, "auth_settings_v2", {}) != {} ? [1] : []

    content {
      auth_enabled           = lookup(each.value.auth_settings_v2, "enabled", false)
      config_file_path       = lookup(each.value.auth_settings_v2, "config_file_path", null)
      default_provider       = lookup(each.value.auth_settings_v2, "default_provider", null)
      runtime_version        = lookup(each.value.auth_settings_v2, "runtime_version", null)
      unauthenticated_action = lookup(each.value.auth_settings_v2, "unauthenticated_client_action", null)

      dynamic "active_directory_v2" {
        for_each = lookup(each.value.auth_settings_v2, "active_directory", {}) != {} ? [1] : []

        content {
          client_id                  = can(each.value.auth_settings_v2.active_directory.client_id_key) ? var.azuread_applications[try(each.value.auth_settings_v2.active_directory.client_id_lz_key, var.client_config.landingzone_key)][each.value.auth_settings_v2.active_directory.client_id_key].application_id : each.value.auth_settings_v2.active_directory.client_id
          tenant_auth_endpoint       = each.value.auth_settings_v2.active_directory.tenant_auth_endpoint
          client_secret_setting_name = lookup(each.value.auth_settings_v2.active_directory, "client_secret_setting_name", null)
          jwt_allowed_groups         = lookup(each.value.auth_settings_v2.active_directory, "jwt_allowed_groups", [])
          allowed_groups             = lookup(each.value.auth_settings_v2.active_directory, "allowed_groups", [])
          allowed_identities         = lookup(each.value.auth_settings_v2.active_directory, "allowed_identities", [])
          allowed_applications       = lookup(each.value.auth_settings_v2.active_directory, "allowed_applications", [])
          login_parameters           = lookup(each.value.auth_settings_v2.active_directory, "login_parameters", {})
        }
      }

      dynamic "facebook_v2" {
        for_each = lookup(each.value.auth_settings_v2, "facebook", {}) != {} ? [1] : []

        content {
          app_id                  = each.value.auth_settings_v2.facebook.app_id
          app_secret_setting_name = each.value.auth_settings_v2.facebook.app_secret_setting_name
          graph_api_version       = lookup(each.value.auth_settings_v2.facebook, "graph_api_version", null)
          login_scopes            = lookup(each.value.auth_settings_v2.facebook, "oauth_scopes", null)
        }
      }

      dynamic "google_v2" {
        for_each = lookup(each.value.auth_settings_v2, "google", {}) != {} ? [1] : []

        content {
          client_id                  = each.value.auth_settings_v2.google.client_id
          client_secret_setting_name = each.value.auth_settings_v2.google.client_secret_setting_name
          login_scopes               = lookup(each.value.auth_settings_v2.google, "oauth_scopes", null)
        }
      }

      dynamic "microsoft_v2" {
        for_each = lookup(each.value.auth_settings_v2, "microsoft", {}) != {} ? [1] : []

        content {
          client_id                  = can(each.value.auth_settings_v2.microsoft.client_id_key) ? var.azuread_applications[try(each.value.auth_settings_v2.microsoft.client_id_lz_key, var.client_config.landingzone_key)][each.value.auth_settings_v2.microsoft.client_id_key].application_id : each.value.auth_settings_v2.microsoft.client_id
          client_secret_setting_name = each.value.auth_settings_v2.microsoft.client_secret_setting_name
          login_scopes               = lookup(each.value.auth_settings_v2.microsoft, "oauth_scopes", null)
        }
      }

      dynamic "twitter_v2" {
        for_each = lookup(each.value.auth_settings_v2, "twitter", {}) != {} ? [1] : []

        content {
          consumer_key                 = each.value.auth_settings_v2.twitter.consumer_key
          consumer_secret_setting_name = each.value.auth_settings_v2.twitter.consumer_secret_setting_name
        }
      }

      login {
        logout_endpoint                   = try(each.value.auth_settings_v2.login.logout_endpoint, null)
        token_store_enabled               = try(each.value.auth_settings_v2.login.token_store_enabled, null)
        token_refresh_extension_time      = try(each.value.auth_settings_v2.login.token_refresh_extension_time, null)
        token_store_path                  = try(each.value.auth_settings_v2.login.token_store_path, null)
        token_store_sas_setting_name      = try(each.value.auth_settings_v2.login.token_store_sas_setting_name, null)
        preserve_url_fragments_for_logins = try(each.value.auth_settings_v2.login.preserve_url_fragments_for_logins, null)
        allowed_external_redirect_urls    = try(each.value.auth_settings_v2.login.allowed_external_redirect_urls, null)
        cookie_expiration_convention      = try(each.value.auth_settings_v2.login.cookie_expiration_convention, null)
        cookie_expiration_time            = try(each.value.auth_settings_v2.login.cookie_expiration_time, null)
        validate_nonce                    = try(each.value.auth_settings_v2.login.validate_nonce, null)
        nonce_expiration_time             = try(each.value.auth_settings_v2.login.nonce_expiration_time, null)
      }
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      site_config[0].scm_type
    ]
  }
}
