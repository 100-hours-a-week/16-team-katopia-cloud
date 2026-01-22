variable "name" {
  description = "ALB name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the target groups."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ALB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the ALB."
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener."
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "target_groups" {
  description = "Target group definitions keyed by logical name."
  type = map(object({
    name                  = string
    port                  = number
    protocol              = string
    health_check_path     = string
    health_check_matcher  = string
  }))
}

variable "default_target_group_key" {
  description = "Target group key to use for the default HTTPS action."
  type        = string
}

variable "path_rules" {
  description = "Path-based routing rules."
  type = list(object({
    priority         = number
    target_group_key = string
    path_patterns    = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}
