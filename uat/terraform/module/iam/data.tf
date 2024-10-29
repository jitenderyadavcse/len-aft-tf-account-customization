data "aws_ssm_parameter" "role_mappings" {
  provider = aws.vended_account

  name = "/aft/account-request/custom-fields/role_mappings"
}

# data "aws_ssoadmin_instances" "main" {
#   provider = aws.ct_management
# }

# data "aws_ssoadmin_permission_set" "main" {
#   provider = aws.ct_management

#   instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]
#   name         = "AWSReadOnlyAccess"
# }

# data "aws_identitystore_group" "main" {
#   provider = aws.ct_management

#   identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]

#   alternate_identifier {
#     unique_attribute {
#       attribute_path  = "DisplayName"
#       attribute_value = "mainGroup"
#     }
#   }
# }
