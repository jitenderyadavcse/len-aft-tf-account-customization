locals {
  # mandated_tags = {
  #   "ApplicationName"  = lookup(var.common_tags, "ApplicationName")
  #   "ApplicationID"    = lookup(var.common_tags, "ApplicationID")
  #   "ApplicationOwner" = lookup(var.common_tags, "ApplicationOwner")
  #   "CostCenter"       = lookup(var.common_tags, "CostCenter")
  # }
  allowed_tags = {
    "ApplicationName"  = lookup(var.allowed_tags, "ApplicationName")
    "ApplicationID"    = lookup(var.allowed_tags, "ApplicationID")
    "ApplicationOwner" = lookup(var.allowed_tags, "ApplicationOwner")
    "CostCenter"       = lookup(var.allowed_tags, "CostCenter")
  }
}
