variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "public_subnet_az" {
  description = "Availability zone for the public subnet."
  type        = string
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "security_group_name" {
  description = "Name of the security group."
  type        = string
}

variable "security_group_ingress_rules" {
  description = "Ingress rules for the security group."
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    security_groups  = list(string)
    prefix_list_ids  = list(string)
    self             = bool
  }))
}

variable "security_group_egress_rules" {
  description = "Egress rules for the security group."
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    security_groups  = list(string)
    prefix_list_ids  = list(string)
    self             = bool
  }))
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access."
  type        = string
}

variable "iam_role_name" {
  description = "IAM role name for EC2."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2."
  type        = string
}

variable "iam_managed_policy_arns" {
  description = "Managed policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "iam_inline_policy_name" {
  description = "Name of the inline policy to attach to the role."
  type        = string
  default     = null
}

variable "iam_inline_policy_json" {
  description = "Inline policy JSON to attach to the role."
  type        = string
  default     = null
}
