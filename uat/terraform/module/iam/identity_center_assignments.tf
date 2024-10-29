# locals {
#   role_mappings_raw = jsondecode(data.aws_ssm_parameter.role_mappings.value)
#   role_mappings = {
#     for key, value in local.role_mappings_raw :
#     key => replace(value, " ", "")
#   }
# }


# resource "aws_ssoadmin_account_assignment" "main" {
#   instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
#   permission_set_arn = data.aws_ssoadmin_permission_set.main.arn

#   principal_id   = data.aws_identitystore_group.main.group_id
#   principal_type = "GROUP"

#   target_id   = "123456789012"
#   target_type = "AWS_ACCOUNT"
# }