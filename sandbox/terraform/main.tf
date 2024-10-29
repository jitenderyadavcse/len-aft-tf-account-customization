data "aws_ssm_parameter" "app_code" {
  provider = aws.vended_account
  name = "/aft/account-request/custom-fields/app_code"
}
data "aws_ssm_parameter" "budget" {
  provider = aws.vended_account
  name = "/aft/account-request/custom-fields/budget"
}
data "aws_ssm_parameter" "budget_alert_email" {
  provider = aws.vended_account
  name = "/aft/account-request/custom-fields/budget_alert_email"
}
data "aws_ssm_parameter" "tags" {
  provider = aws.vended_account
  name = "/aft/account-request/custom-fields/mandatory_tags"
}

data "aws_ssm_parameter" "allowed_tags" {
  provider = aws.vended_account
  name = "/aft/account-request/custom-fields/allowed_tags"
}

locals {
  common_tags = {
    for key, value in jsondecode(data.aws_ssm_parameter.tags.value) : 
    replace(key, " ", "") => value
  }

  allowed_tags = {
    for key, value in jsondecode(data.aws_ssm_parameter.allowed_tags.value) : 
    replace(key, " ", "") => value
  }

  budget_alert_email = try(data.aws_ssm_parameter.budget_alert_email.value, null)
}

module "vpc" {
  providers = {
    aws.vended_account = aws.vended_account
    aws.network_management = aws.network_management
    aws.aft_management = aws.aft_management
  }
  source = "./module/vpc"
  common_tags = local.common_tags
  vpc_name = "len-${var.env}-${data.aws_ssm_parameter.app_code.value}-vpc-01"
  transit_gateway_id = var.transit_gateway_id
  availability_zones = var.availability_zones
}

module "budget" {
  providers = {
    aws.vended_account = aws.vended_account
  }
  source = "./module/budget"
  budget = data.aws_ssm_parameter.budget.value
  notification_subscriber_email = split(",",data.aws_ssm_parameter.budget_alert_email.value)
}

module "iam_roles" {
  providers = {
    aws.vended_account = aws.vended_account
    aws.ct_management = aws.ct_management
  }
  source = "./module/iam"
  common_tags = local.common_tags
  ct_management_account_id = var.ct_management_account_id
}

module "tag_enforcement" {
  providers = {
    aws.vended_account = aws.vended_account
    aws.ct_management = aws.ct_management
  }
  source = "./module/tag_enforcement"
  allowed_tags = local.allowed_tags
}