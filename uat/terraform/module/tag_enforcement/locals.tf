locals {
  mandated_tags = {
    "ApplicationName"  = lookup(var.common_tags, "ApplicationName")
    "ApplicationID"    = lookup(var.common_tags, "ApplicationID")
    "ApplicationOwner" = lookup(var.common_tags, "ApplicationOwner")
    "CostCenter"       = lookup(var.common_tags, "CostCenter")
  }  
  mandatory_tags = jsondecode(data.aws_ssm_parameter.mandatory_tags.value)
}
