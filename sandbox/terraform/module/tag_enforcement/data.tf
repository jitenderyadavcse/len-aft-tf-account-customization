data "aws_caller_identity" "current" {
  provider = aws.vended_account
}
data "aws_ssm_parameter" "app_code" {
  provider = aws.vended_account
  name     = "/aft/account-request/custom-fields/app_code"
}