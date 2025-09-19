resource "azurecaf_name" "app_service" {
  name          = var.name
  resource_type = "azurerm_app_service"
  prefixes      = try(var.settings.name_prefix, null)
  suffixes      = try(var.settings.name_suffix, null)
  random_length = try(var.settings.random_length, 0)
  clean_input   = true
}

resource "azurerm_windows_web_app" "app_service" {
  name                = azurecaf_name.app_service.result
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = var.app_service_plan_id

  client_affinity_enabled         = lookup(var.settings, "client_affinity_enabled", null)
  client_certificate_enabled      = lookup(var.settings, "client_cert_enabled", null)
  enabled                         = lookup(var.settings, "enabled", null)
  https_only                      = lookup(var.settings, "https_only", null)
  key_vault_reference_identity_id = can(var.settings.key_vault_reference_identity.key) ? var.combined_objects.managed_identities[try(var.settings.key_vault_reference_identity.lz_key, var.client_config.landingzone_key)][var.settings.key_vault_reference_identity.key].id : try(var.settings.key_vault_reference_identity.id, null)
  virtual_network_subnet_id       = var.subnet_id

  tags = merge(local.tags, try(var.settings.tags, {}))

  dynamic "identity" {
    for_each = try(var.identity, null) == null ? [] : [1]

    content {
      type         = var.identity.type
      identity_ids = lower(var.identity.type) == "userassigned" ? local.managed_identities : null
    }
  }

  site_config {
    always_on                         = lookup(var.settings.site_config, "always_on", null)
    app_command_line                  = lookup(var.settings.site_config, "app_command_line", null)
    auto_heal_enabled                 = lookup(var.settings.site_config, "auto_heal_enabled", null)
    default_documents                 = lookup(var.settings.site_config, "default_documents", null)
    ftps_state                        = lookup(var.settings.site_config, "ftps_state", "FtpsOnly")
    health_check_path                 = lookup(var.settings.site_config, "health_check_path", null)
    health_check_eviction_time_in_min = lookup(var.settings.site_config, "health_check_eviction_time_in_min", null)
    http2_enabled                     = lookup(var.settings.site_config, "http2_enabled", null)
    load_balancing_mode               = lookup(var.settings.site_config, "load_balancing_mode", null)
    local_mysql_enabled               = lookup(var.settings.site_config, "local_mysql_enabled", null)
    managed_pipeline_mode             = lookup(var.settings.site_config, "managed_pipeline_mode", null)
    minimum_tls_version               = lookup(var.settings.site_config, "minimum_tls_version", null)
    windows_fx_version                = lookup(var.settings.site_config, "windows_fx_version", null)
    remote_debugging_enabled          = lookup(var.settings.site_config, "remote_debugging_enabled", null)
    remote_debugging_version          = lookup(var.settings.site_config, "remote_debugging_version", null)
    use_32_bit_worker                 = lookup(var.settings.site_config, "use_32_bit_worker", null)
    vnet_route_all_enabled            = lookup(var.settings.site_config, "vnet_route_all_enabled", null)
    websockets_enabled                = lookup(var.settings.site_config, "websockets_enabled", null)
    worker_count                      = lookup(var.settings.site_config, "worker_count", null)
    scm_type                          = lookup(var.settings.site_config, "scm_type", null)

    application_stack {
      current_stack            = try(var.settings.site_config.application_stack.current_stack, null)
      docker_image_name        = try(var.settings.site_config.application_stack.docker_image_name, null)
      docker_registry_url      = try(var.settings.site_config.application_stack.docker_registry_url, null)
      docker_registry_username = try(var.settings.site_config.application_stack.docker_registry_username, null)
      docker_registry_password = try(var.settings.site_config.application_stack.docker_registry_password, null)

      # Built-in stacks
      python_version      = try(var.settings.site_config.application_stack.python_version, null)
      node_version        = try(var.settings.site_config.application_stack.node_version, null)
      php_version         = try(var.settings.site_config.application_stack.php_version, null)
      dotnet_version      = try(var.settings.site_config.application_stack.dotnet_version, null)
      dotnet_core_version = try(var.settings.site_config.application_stack.dotnet_core_version, null)
      tomcat_version      = try(var.settings.site_config.application_stack.tomcat_version, null)
      java_version        = try(var.settings.site_config.application_stack.java_version, null)
      python              = try(var.settings.site_config.application_stack.python, null)
    }

    dynamic "auto_heal_setting" {
      for_each = lookup(var.settings, "auto_heal_setting", {}) != {} ? [1] : []

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
    # Optional IP restrictions
    dynamic "ip_restriction" {
      for_each = try(var.settings.site_config.ip_restriction, {})
      content {
        name                      = try(ip_restriction.value.name, null)
        priority                  = try(ip_restriction.value.priority, null)
        action                    = try(ip_restriction.value.action, null)
        ip_address                = try(ip_restriction.value.ip_address, null)
        service_tag               = try(ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(ip_restriction.value.virtual_network_subnet_id, null)
        headers {
          x_azure_fdid      = try(ip_restriction.value.headers.x_azure_fdid, null)
          x_fd_health_probe = try(ip_restriction.value.headers.x_fd_health_probe, null)
          x_forwarded_for   = try(ip_restriction.value.headers.x_forwarded_for, null)
          x_forwarded_host  = try(ip_restriction.value.headers.x_forwarded_host, null)
        }
      }
    }

    # Optional SCM IP restrictions
    dynamic "scm_ip_restriction" {
      for_each = try(var.settings.site_config.scm_ip_restriction, {})
      content {
        name                      = try(scm_ip_restriction.value.name, null)
        priority                  = try(scm_ip_restriction.value.priority, null)
        action                    = try(scm_ip_restriction.value.action, null)
        ip_address                = try(scm_ip_restriction.value.ip_address, null)
        service_tag               = try(scm_ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(scm_ip_restriction.value.virtual_network_subnet_id, null)
        headers {
          x_azure_fdid      = try(scm_ip_restriction.value.headers.x_azure_fdid, null)
          x_fd_health_probe = try(scm_ip_restriction.value.headers.x_fd_health_probe, null)
          x_forwarded_for   = try(scm_ip_restriction.value.headers.x_forwarded_for, null)
          x_forwarded_host  = try(scm_ip_restriction.value.headers.x_forwarded_host, null)
        }
      }
    }
    dynamic "virtual_application" {
      for_each = try(var.settings.site_config.virtual_application, {})
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

  app_settings = local.app_settings

  dynamic "auth_settings" {
    for_each = lookup(var.settings, "auth_settings", {}) != {} ? [1] : []

    content {
      enabled                        = lookup(var.settings.auth_settings, "enabled", null)
      allowed_external_redirect_urls = lookup(var.settings.auth_settings, "allowed_external_redirect_urls", null)
      default_provider               = lookup(var.settings.auth_settings, "default_provider", null)
      issuer                         = lookup(var.settings.auth_settings, "issuer", null)
      runtime_version                = lookup(var.settings.auth_settings, "runtime_version", null)
      token_refresh_extension_hours  = lookup(var.settings.auth_settings, "token_refresh_extension_hours", null)
      token_store_enabled            = lookup(var.settings.auth_settings, "token_store_enabled", null)
      unauthenticated_client_action  = lookup(var.settings.auth_settings, "unauthenticated_client_action", null)

      dynamic "active_directory" {
        for_each = lookup(var.settings.auth_settings, "active_directory", {}) != {} ? [1] : []

        content {
          client_id         = can(var.settings.auth_settings.active_directory.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings.active_directory.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings.active_directory.client_id_key].application_id : var.settings.auth_settings.active_directory.client_id
          client_secret     = can(var.settings.auth_settings.active_directory.client_secret_key) ? var.azuread_service_principal_passwords[try(var.settings.auth_settings.active_directory.client_secret_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings.active_directory.client_secret_key].service_principal_password : try(var.settings.auth_settings.active_directory.client_secret, null)
          allowed_audiences = lookup(var.settings.auth_settings.active_directory, "allowed_audiences", null)
        }
      }

      dynamic "facebook" {
        for_each = lookup(var.settings.auth_settings, "facebook", {}) != {} ? [1] : []

        content {
          app_id       = var.settings.auth_settings.facebook.app_id
          app_secret   = var.settings.auth_settings.facebook.app_secret
          oauth_scopes = lookup(var.settings.auth_settings.facebook, "oauth_scopes", null)
        }
      }

      dynamic "google" {
        for_each = lookup(var.settings.auth_settings, "google", {}) != {} ? [1] : []

        content {
          client_id     = var.settings.auth_settings.google.client_id
          client_secret = var.settings.auth_settings.google.client_secret
          oauth_scopes  = lookup(var.settings.auth_settings.google, "oauth_scopes", null)
        }
      }

      dynamic "microsoft" {
        for_each = lookup(var.settings.auth_settings, "microsoft", {}) != {} ? [1] : []

        content {
          client_id     = var.settings.auth_settings.microsoft.client_id
          client_secret = var.settings.auth_settings.microsoft.client_secret
          oauth_scopes  = lookup(var.settings.auth_settings.microsoft, "oauth_scopes", null)
        }
      }

      dynamic "twitter" {
        for_each = lookup(var.settings.auth_settings, "twitter", {}) != {} ? [1] : []

        content {
          consumer_key    = var.settings.auth_settings.twitter.consumer_key
          consumer_secret = var.settings.auth_settings.twitter.consumer_secret
        }
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = lookup(var.settings, "auth_settings_v2", {}) != {} ? [1] : []

    content {
      auth_enabled           = lookup(var.settings.auth_settings_v2, "enabled", false)
      config_file_path       = lookup(var.settings.auth_settings_v2, "config_file_path", null)
      default_provider       = lookup(var.settings.auth_settings_v2, "default_provider", null)
      runtime_version        = lookup(var.settings.auth_settings_v2, "runtime_version", null)
      unauthenticated_action = lookup(var.settings.auth_settings_v2, "unauthenticated_client_action", null)
      dynamic "active_directory_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "active_directory", {}) != {} ? [1] : []

        content {
          client_id                  = can(var.settings.auth_settings_v2.active_directory.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.active_directory.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.active_directory.client_id_key].application_id : var.settings.auth_settings_v2.active_directory.client_id
          tenant_auth_endpoint       = var.settings.auth_settings_v2.active_directory.tenant_auth_endpoint
          allowed_audiences          = lookup(var.settings.auth_settings_v2.active_directory, "allowed_audiences", null)
          client_secret_setting_name = lookup(var.settings.auth_settings_v2.active_directory, "client_secret_setting_name", null)
          jwt_allowed_groups         = lookup(var.settings.auth_settings_v2.active_directory, "jwt_allowed_groups", [])
          allowed_groups             = lookup(var.settings.auth_settings_v2.active_directory, "allowed_groups", [])
          allowed_identities         = lookup(var.settings.auth_settings_v2.active_directory, "allowed_identities", [])
          allowed_applications       = lookup(var.settings.auth_settings_v2.active_directory, "allowed_applications", [])
          login_parameters           = lookup(var.settings.auth_settings_v2.active_directory, "login_parameters", {})
        }
      }

      dynamic "facebook_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "facebook", {}) != {} ? [1] : []

        content {
          app_id                  = var.settings.auth_settings_v2.facebook.app_id
          app_secret_setting_name = var.settings.auth_settings_v2.facebook.app_secret_setting_name
          graph_api_version       = lookup(var.settings.auth_settings_v2.facebook, "graph_api_version", null)
          login_scopes            = lookup(var.settings.auth_settings_v2.facebook, "oauth_scopes", null)
        }
      }

      dynamic "google_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "google", {}) != {} ? [1] : []

        content {
          client_id                  = var.settings.auth_settings_v2.google.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.google.client_secret_setting_name
          login_scopes               = lookup(var.settings.auth_settings_v2.google, "oauth_scopes", null)
        }
      }

      dynamic "microsoft_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "microsoft", {}) != {} ? [1] : []

        content {
          client_id                  = can(var.settings.auth_settings_v2.microsoft.client_id_key) ? var.azuread_applications[try(var.settings.auth_settings_v2.microsoft.client_id_lz_key, var.client_config.landingzone_key)][var.settings.auth_settings_v2.microsoft.client_id_key].application_id : var.settings.auth_settings_v2.microsoft.client_id
          client_secret_setting_name = var.settings.auth_settings_v2.microsoft.client_secret_setting_name
          login_scopes               = lookup(var.settings.auth_settings_v2.microsoft, "oauth_scopes", null)
        }
      }

      dynamic "twitter_v2" {
        for_each = lookup(var.settings.auth_settings_v2, "twitter", {}) != {} ? [1] : []

        content {
          consumer_key                 = var.settings.auth_settings_v2.twitter.consumer_key
          consumer_secret_setting_name = var.settings.auth_settings_v2.twitter.consumer_secret_setting_name
        }
      }

      login {
        logout_endpoint                   = try(var.settings.auth_settings_v2.login.logout_endpoint, null)
        token_store_enabled               = try(var.settings.auth_settings_v2.login.token_store_enabled, null)
        token_refresh_extension_time      = try(var.settings.auth_settings_v2.login.token_refresh_extension_time, null)
        token_store_path                  = try(var.settings.auth_settings_v2.login.token_store_path, null)
        token_store_sas_setting_name      = try(var.settings.auth_settings_v2.login.token_store_sas_setting_name, null)
        preserve_url_fragments_for_logins = try(var.settings.auth_settings_v2.login.preserve_url_fragments_for_logins, null)
        allowed_external_redirect_urls    = try(var.settings.auth_settings_v2.login.allowed_external_redirect_urls, null)
        cookie_expiration_convention      = try(var.settings.auth_settings_v2.login.cookie_expiration_convention, null)
        cookie_expiration_time            = try(var.settings.auth_settings_v2.login.cookie_expiration_time, null)
        validate_nonce                    = try(var.settings.auth_settings_v2.login.validate_nonce, null)
        nonce_expiration_time             = try(var.settings.auth_settings_v2.login.nonce_expiration_time, null)
      }
    }
  }

  dynamic "backup" {
    for_each = lookup(var.settings, "backup", {}) != {} ? [1] : []
    content {
      name                = try(var.settings.backup.name, null)
      enabled             = try(var.settings.backup.enabled, null)
      storage_account_url = try(local.backup_sas_url, try(var.settings.backup.storage_account_url, null))

      dynamic "schedule" {
        for_each = try(var.settings.backup.schedule, null) == null ? [] : [1]
        content {
          frequency_interval       = var.settings.backup.schedule.frequency_interval
          frequency_unit           = var.settings.backup.schedule.frequency_unit
          keep_at_least_one_backup = try(var.settings.backup.schedule.keep_at_least_one_backup, null)
          retention_period_days    = try(var.settings.backup.schedule.retention_period_in_days, null)
          start_time               = try(var.settings.backup.schedule.start_time, null)
        }
      }
    }
  }

  dynamic "connection_string" {
    for_each = try(var.settings.connection_strings, [])
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "logs" {
    for_each = lookup(var.settings, "logs", {}) != {} ? [1] : []
    content {
      detailed_error_messages = try(var.settings.logs.detailed_error_messages, null)
      failed_request_tracing  = try(var.settings.logs.failed_request_tracing, null)
      application_logs {
        file_system_level = try(var.settings.logs.application_logs.file_system_level, null)
      }
      http_logs {
        file_system {
          retention_in_days = try(var.settings.logs.http_logs.file_system.retention_in_days, null)
          retention_in_mb   = try(var.settings.logs.http_logs.file_system.retention_in_mb, null)
        }
        azure_blob_storage {
          sas_url           = try(local.http_logs_sas_url, try(var.settings.logs.http_logs.azure_blob_storage.sas_url, null))
          retention_in_days = try(var.settings.logs.http_logs.azure_blob_storage.retention_in_days, null)
        }
      }
    }
  }

  dynamic "storage_account" {
    for_each = lookup(var.settings, "storage_account", [])
    content {
      name         = storage_account.value.name
      type         = storage_account.value.type
      account_name = can(storage_account.value.account_key) ? var.storage_accounts[try(storage_account.value.lz_key, var.client_config.landingzone_key)][storage_account.value.account_key].name : try(storage_account.value.account_name, null)
      share_name   = storage_account.value.share_name
      access_key   = can(storage_account.value.account_key) ? var.storage_accounts[try(storage_account.value.lz_key, var.client_config.landingzone_key)][storage_account.value.account_key].primary_access_key : try(storage_account.value.access_key, null)
      mount_path   = lookup(storage_account.value, "mount_path", null)
    }
  }

  # Sticky settings for slots
  dynamic "sticky_settings" {
    for_each = try(var.settings.sticky_settings, null) == null ? [] : [1]
    content {
      app_setting_names       = try(var.settings.sticky_settings.app_setting_names, [])
      connection_string_names = try(var.settings.sticky_settings.connection_string_names, [])
    }
  }

}

resource "azurerm_app_service_custom_hostname_binding" "app_service" {
  for_each            = try(var.settings.custom_hostname_binding, {})
  app_service_name    = azurerm_windows_web_app.app_service.name
  resource_group_name = local.resource_group_name
  hostname            = each.value.hostname
  ssl_state           = try(each.value.ssl_state, null)
  thumbprint          = try(each.value.thumbprint, null)
}