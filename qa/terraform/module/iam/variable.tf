variable "role_mappings" {
    type = map(string)
    description = "Mapping of Roles and AD groups"
    default = {
      "EngineeringContributor" = "Test7 App Contributors"
      "Reader" = "Test 7 App Readers"
    }
}
variable "common_tags" {
  type = map(string)
  description = "Mandatory tags enforced"
}

variable "ct_management_account_id" {
  description = "Control Tower Management Account Id"
  type        = string
  validation {
    condition     = can(regex("^\\d{12}$", var.ct_management_account_id))
    error_message = "Variable var: ct_management_account_id is not valid."
  }
}