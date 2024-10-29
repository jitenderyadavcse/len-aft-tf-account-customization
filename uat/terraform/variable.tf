variable "env" {
  description = "Use this variable to customize names to identify resources to this template"
  default = "uat"
}

variable "ct_management_account_id" {
  description = "Control Tower Management Account Id"
  type        = string
  validation {
    condition     = can(regex("^\\d{12}$", var.ct_management_account_id))
    error_message = "Variable var: ct_management_account_id is not valid."
  }
}
variable "network_management_account_id" {
  description = "Network Management Account Id"
  type        = string
  validation {
    condition     = can(regex("^\\d{12}$", var.network_management_account_id))
    error_message = "Variable var: ct_management_account_id is not valid."
  }
}
variable "log_archive_account_id" {
  description = "Log Archive Account Id"
  type        = string
  validation {
    condition     = can(regex("^\\d{12}$", var.log_archive_account_id))
    error_message = "Variable var: log_archive_account_id is not valid."
  }
}
variable "audit_account_id" {
  description = "Audit Account Id"
  type        = string
  validation {
    condition     = can(regex("^\\d{12}$", var.audit_account_id))
    error_message = "Variable var: audit_account_id is not valid."
  }
}

variable "aft_management_account_id" {
  description = "AFT Management Account ID"
  type        = string
  validation {
    condition     = can(regex("^\\d{12}$", var.aft_management_account_id))
    error_message = "Variable var: aft_management_account_id is not valid."
  }
}

variable "ct_home_region" {
  description = "The region from which this module will be executed. This MUST be the same region as Control Tower is deployed."
  type        = string
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d", var.ct_home_region))
    error_message = "Variable var: region is not valid."
  }
}

variable "tf_backend_secondary_region" {
  type        = string
  description = "AFT creates a backend for state tracking for its own state as well as OSS cases. The backend's primary region is the same as the AFT region, but this defines the secondary region to replicate to."
  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d", var.tf_backend_secondary_region))
    error_message = "Variable var: tf_backend_secondary_region is not valid."
  }
}
variable "transit_gateway_id" {
  type = string
  description = "Hub transit gateway which all VPCs will be peered with"
}

variable "availability_zones" {
  description = "The availability zones in which the default subnets need to be created."
  type        = list(string)
}