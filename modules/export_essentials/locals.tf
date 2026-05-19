locals {
  json_schema = jsondecode(file("${path.module}/schema/definition.json"))
}

locals {
  json_data = {
    schema_version = local.json_schema.schema_version
    data = {
      for key, values in local.json_schema.resource_types : key => {
        for instance_name, instance_data in coalesce(try(var.remote_objects[key], null), {}) : instance_name => {
          for output_key in values : output_key => instance_data[output_key] if can(instance_data[output_key])
        }
      }
    }
  }
}
