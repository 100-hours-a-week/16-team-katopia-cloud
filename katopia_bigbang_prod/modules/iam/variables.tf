variable "role_name" {
  description = "Name of the IAM role for EC2."
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile."
  type        = string
}

variable "managed_policy_arns" {
  description = "Managed policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "inline_policy_name" {
  description = "Name of the inline policy to attach to the role."
  type        = string
  default     = null
}

variable "inline_policy_json" {
  description = "Inline policy JSON to attach to the role."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}
