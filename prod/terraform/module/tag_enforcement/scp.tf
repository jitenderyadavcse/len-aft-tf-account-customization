####################################
## Refer to scp_deny_create_on_no_tag.json for the services for which tags are 
## enforced. 
## Note:  1. For every new AWS service, the correct actions and resources names
##        need to be populated
##        2. While adding new resources types and actions, if policy file grows
##        larger than AWS limit of 10000 characters, create additional SCPs
####################################

locals {
  app_id = data.aws_ssm_parameter.app_code

  # Construct policy for Deny Create when Tags are not present
  scp_deny_actions_list_policy_file_path = "${path.module}/policies/scp_deny_create_on_no_tag.json"
  scp_deny_actions_onNoTag = jsondecode(file(local.scp_deny_actions_list_policy_file_path))
  scp_statement = {
    "Version": "2012-10-17",
	  "Statement": [
      for tag, value in local.mandated_tags:
      {
        "Effect": "Deny",
        "Resource": local.scp_deny_actions_onNoTag.resources,
        "Sid": "DenyCreateWithout${tag}",
        "Action": local.scp_deny_actions_onNoTag.actions,
        "Condition": {
          "Null": {
            "aws:RequestTag/${tag}": "true"
          }
        }
      }
    ]
  }
}

resource "aws_organizations_policy" "mandatory_tags" {
  provider = aws.ct_management

  #name        = "DenyCreateActionsWithoutMandatoryTags-${local.app_id.value}"
  name        = "DenyCreateActionsWithoutMandatoryTags-${data.aws_caller_identity.current.account_id}"
  description = "Deny resource creation without mandatory tags, set by Account Factory"
  type        = "SERVICE_CONTROL_POLICY"
  
  content = jsonencode(local.scp_statement)
}
resource "aws_organizations_policy_attachment" "mandatory_tags" {
  provider = aws.ct_management
  
  policy_id = aws_organizations_policy.mandatory_tags.id
  target_id = data.aws_caller_identity.current.account_id
}
