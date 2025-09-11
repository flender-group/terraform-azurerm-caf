locals {
  nsrecords = [
    for ns in var.ns_records : {
      nsdname = ns
    }
  ]
}

resource "azapi_resource" "dns_delegation" {
  type      = "Microsoft.Network/dnsZones/NS@2018-05-01"
  parent_id = var.parent_zone_id
  name      = var.settings.name
  body = jsonencode({
    properties = {
      NSRecords = local.nsrecords
      TTL = try(var.settings.ttl, 300)
    }
  })
  tags  = merge(var.base_tags, try(var.settings.tags, {}))
  schema_validation_enabled = false
  response_export_values    = ["*"]
}