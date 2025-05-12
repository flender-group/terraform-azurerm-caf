gallery_application = {
  linux = {
    resource_group_key = "gallery_app"
    supported_os_type = "Linux"
    name = "Linux-App"
    description = "tcpdump"
    shared_image_gallery_destination = {
      gallery_key = "crowdtrike_app"
    }
  }
}