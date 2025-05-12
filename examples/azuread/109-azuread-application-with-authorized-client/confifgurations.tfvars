global_settings = {
  default_region = "region1"
  regions = {
    region1 = "uksouth"
  }
  random_length = 5
}


azuread_apps = {
  test_client = {
    useprefix                      = true
    application_name               = "test-client"
    sign_in_audience               = "AzureADMyOrg"
    prevent_duplicate_names        = true
    fallback_public_client_enabled = true

    single_page_application = {
      redirect_uris = [
        "https://uri1.aztfmod.github.io/",
        "https://uri2.aztfmod.github.io/"
      ]
    }
  }
}


azuread_applications = {
  test_client_v1 = {
    useprefix        = true
    application_name = "test-client-v1"
    public_client    = true

    single_page_application = {
      redirect_uris = [
        "https://uri1.aztfmod.github.io/",
        "https://uri2.aztfmod.github.io/"
      ]
    }

    api = {
      mapped_claims_enabled          = true
      requested_access_token_version = 2

      oauth2_permission_scopes = [
        {
          admin_consent_description  = "Allow to administer app."
          admin_consent_display_name = "Administer app"
          enabled                    = true
          # Generate UUID: uuidgen | tr "[:upper:]" "[:lower:]"
          id    = "d4c3605a-b327-35c5-f04d-77f7fcdd4995"
          type  = "Admin"
          value = "app"
        },
        {
          admin_consent_description  = "Allow to administer app2."
          admin_consent_display_name = "Administer app2"
          enabled                    = true
          type  = "Admin"
          value = "app2"
        }
      ]

      pre_authorized_clients = {
        azure_powershell = {
          authorized_client_id = "1950a258-227b-4e31-a9cf-717495945fc2"
          selected_scopes       = ["app", "app2"]
        }
        azure_cli = {
          authorized_client_id = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
          selected_scopes       = ["app2"]
        }
      }

    }
  }
}