locals {
  policy_map = {
    EngineeringContributor = [
      "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
      "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    ]
    Reader = [
      "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    ]
  }

  flattened_policies = merge([
    for role, policy_arns in local.policy_map : {
      for idx, policy_arn in policy_arns : 
        "${role}-${idx}" => {
          role_name  = role
          policy_arn = policy_arn
        }
    }
  ]...)
}

locals {
  role_mappings_raw = jsondecode(data.aws_ssm_parameter.role_mappings.value)
  role_mappings = {
    for key, value in local.role_mappings_raw :
    key => replace(value, " ", "")
  }
}

resource "aws_iam_role" "custom_role" {
  provider = aws.vended_account
  for_each = local.policy_map
  name = local.role_mappings[each.key]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
            "AWS": [
                "arn:aws:iam::${var.ct_management_account_id}:root"
            ]
        }
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  provider = aws.vended_account
  for_each = local.flattened_policies
  role       = local.role_mappings[each.value.role_name]
  policy_arn = each.value.policy_arn

  depends_on = [ aws_iam_role.custom_role ]
}

# AWS Control Tower didn't enroll the newly vended account because this role was not existent
# Below code is a possible workaround (not tested)
# Before running this code, find the mandatory SCP attached at the Workload or Env OU level
# which denies iam:createRole access

# resource "aws_iam_role" "aws_control_tower_execution" {
#   provider = aws.vended_account
#   name = "AWSControlTowerExecution"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = "AllowControlTowerRegistration"
#         Principal = {
#           "AWS": "arn:aws:iam::${var.ct_management_account_id}:root"
#         }
#       }
#     ]
#   })
#   tags = var.common_tags
# }

# resource "aws_iam_role_policy_attachment" "admin-access-policy-attach" {
#   provider = aws.vended_account
#   role       = aws_iam_role.aws_control_tower_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

#   depends_on = [ aws_iam_role.aws_control_tower_execution ]
# }