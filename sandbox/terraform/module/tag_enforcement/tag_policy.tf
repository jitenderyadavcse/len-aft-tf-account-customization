locals {
  tag_policy_enforced_services_file_path = "${path.module}/policies/tag_policy_enforced_for.json"
  tag_policy_enforced_services_json      = jsondecode(file(local.tag_policy_enforced_services_file_path))
  tag_policies = {
    for key, value in local.allowed_tags :
    replace(key, " ", "") => {
      tags = {
        replace(key, " ", "") = {
          tag_key      = { "@@assign" = replace(key, " ", "") }
          tag_value    = { "@@assign" = split(",", value) }
          enforced_for = local.tag_policy_enforced_services_json
        }
      }
    }
  }
}

resource "aws_organizations_policy" "tag_enforcement_policy" {
  provider = aws.ct_management
  for_each = local.tag_policies

  #name    = "tag-policy-mandatory-tags-enforcement-${data.aws_ssm_parameter.app_code.value}-${each.key}"
  name    = "tag-policy-mandatory-tags-enforcement-${data.aws_caller_identity.current.account_id}-${each.key}"
  type    = "TAG_POLICY"
  content = jsonencode(each.value)
}

resource "aws_organizations_policy_attachment" "tag-policy-attachment" {
  provider = aws.ct_management
  for_each = local.tag_policies

  policy_id = aws_organizations_policy.tag_enforcement_policy[each.key].id
  target_id = data.aws_caller_identity.current.account_id
}
