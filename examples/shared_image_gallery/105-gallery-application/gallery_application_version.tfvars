gallery_application_version = {
  version_one = {
    name = "1.0.0"
    gallery_application = {
      gallery_key = "shared_gallery"
    }
    install_cmd = <<-EOL
      sudo apt-get update && 
      sudo apt-get install ./tcpdump -y
    EOL
    remove_cmd = <<-EOL
      sudo apt-get update && 
      sudo apt-get purge tcpdump -y
    EOL
    update_cmd = <<-EOL
      sudo apt-get update && 
      sudo apt-get upgrade ./tcpdump -y && 
    EOL
    exclude_from_latest = false
    storage_accounts = {
      sas_policy = {
        expire_in_days = 14
        rotation = {
          days = 7
        }
      }
      container_key = "installer"
      storage_account_key = "crowdstrike"
      blob_name = "tcpdump.deb"
    }
  }
}