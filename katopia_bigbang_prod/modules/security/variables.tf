variable "vpc_id" {
  description = "VPC ID for the security group."
  type        = string
}

variable "name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
  default     = "Managed by Terraform"
}

variable "ingress_rules" {
  description = "Ingress rules for the security group."
  type = list(object({
    description       = string
    from_port         = number
    to_port           = number
    protocol          = string
    cidr_blocks       = list(string)
    ipv6_cidr_blocks  = list(string)
    security_groups   = list(string)
    prefix_list_ids   = list(string)
    self              = bool
  }))
  default = []
}

variable "egress_rules" {
  description = "Egress rules for the security group."
  type = list(object({
    description       = string
    from_port         = number
    to_port           = number
    protocol          = string
    cidr_blocks       = list(string)
    ipv6_cidr_blocks  = list(string)
    security_groups   = list(string)
    prefix_list_ids   = list(string)
    self              = bool
  }))
  default = []
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}
