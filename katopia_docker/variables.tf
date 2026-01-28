variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_app_subnet_cidr_blocks" {
  description = "CIDR blocks for the private app subnets."
  type        = list(string)
}

variable "private_db_subnet_cidr_blocks" {
  description = "CIDR blocks for the private db subnets."
  type        = list(string)
}

variable "public_subnet_azs" {
  description = "Availability zones for the public subnets."
  type        = list(string)
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "alb_security_group_name" {
  description = "ALB security group name."
  type        = string
}

variable "spring_security_group_name" {
  description = "Spring security group name."
  type        = string
}

variable "next_security_group_name" {
  description = "Next security group name."
  type        = string
}

variable "vpc_endpoint_security_group_name" {
  description = "VPC endpoint security group name."
  type        = string
}

variable "vpc_endpoint_name_prefix" {
  description = "Name prefix for VPC endpoints."
  type        = string
  default     = "katopia-docker-vpce"
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

variable "monitoring_ami_id" {
  description = "AMI ID for the monitoring EC2 instance."
  type        = string
}

variable "monitoring_instance_type" {
  description = "Monitoring EC2 instance type override."
  type        = string
  default     = null
}

variable "monitoring_name" {
  description = "Name tag for the monitoring EC2 instance."
  type        = string
  default     = "katopia-docker-monitoring"
}

variable "monitoring_security_group_name" {
  description = "Monitoring security group name."
  type        = string
}

variable "monitoring_iam_role_name" {
  description = "IAM role name for monitoring EC2."
  type        = string
}

variable "monitoring_iam_instance_profile_name" {
  description = "IAM instance profile name for monitoring EC2."
  type        = string
}

variable "monitoring_iam_managed_policy_arns" {
  description = "Managed policy ARNs for monitoring EC2 role."
  type        = list(string)
  default     = []
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

variable "alb_name" {
  description = "ALB name."
  type        = string
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for the ALB."
  type        = string
  default     = null
}

variable "alb_target_groups" {
  description = "Target group definitions keyed by logical name."
  type = map(object({
    name                  = string
    port                  = number
    protocol              = string
    health_check_path     = string
    health_check_matcher  = string
  }))
}

variable "alb_default_target_group_key" {
  description = "Target group key to use for the default HTTPS action."
  type        = string
}

variable "alb_path_rules" {
  description = "Path-based routing rules."
  type = list(object({
    priority         = number
    target_group_key = string
    path_patterns    = list(string)
  }))
  default = []
}

variable "asg_spring_name" {
  description = "Spring ASG name."
  type        = string
}

variable "asg_spring_min_size" {
  description = "Spring ASG minimum size."
  type        = number
}

variable "asg_spring_max_size" {
  description = "Spring ASG maximum size."
  type        = number
}

variable "asg_spring_desired_capacity" {
  description = "Spring ASG desired capacity."
  type        = number
}

variable "asg_spring_target_group_key" {
  description = "Target group key for Spring ASG."
  type        = string
}

variable "asg_spring_health_check_type" {
  description = "Spring ASG health check type (EC2 or ELB)."
  type        = string
  default     = "ELB"
}

variable "asg_spring_health_check_grace_period" {
  description = "Spring ASG health check grace period in seconds."
  type        = number
  default     = 300
}

variable "asg_spring_user_data" {
  description = "Spring ASG user data (raw string)."
  type        = string
  default     = null
}

variable "asg_spring_ami_id" {
  description = "Spring ASG AMI ID override."
  type        = string
  default     = null
}

variable "asg_spring_instance_type" {
  description = "Spring ASG instance type override."
  type        = string
  default     = null
}

variable "asg_spring_cpu_target_utilization" {
  description = "Spring ASG CPU target utilization percentage."
  type        = number
  default     = 60
}

variable "asg_spring_tags" {
  description = "Additional tags to apply to Spring ASG instances."
  type        = map(string)
  default     = {}
}

variable "asg_next_name" {
  description = "Next ASG name."
  type        = string
}

variable "asg_next_min_size" {
  description = "Next ASG minimum size."
  type        = number
}

variable "asg_next_max_size" {
  description = "Next ASG maximum size."
  type        = number
}

variable "asg_next_desired_capacity" {
  description = "Next ASG desired capacity."
  type        = number
}

variable "asg_next_target_group_key" {
  description = "Target group key for Next ASG."
  type        = string
}

variable "asg_next_health_check_type" {
  description = "Next ASG health check type (EC2 or ELB)."
  type        = string
  default     = "ELB"
}

variable "asg_next_health_check_grace_period" {
  description = "Next ASG health check grace period in seconds."
  type        = number
  default     = 300
}

variable "asg_next_user_data" {
  description = "Next ASG user data (raw string)."
  type        = string
  default     = null
}

variable "asg_next_ami_id" {
  description = "Next ASG AMI ID override."
  type        = string
  default     = null
}

variable "asg_next_instance_type" {
  description = "Next ASG instance type override."
  type        = string
  default     = null
}

variable "asg_next_cpu_target_utilization" {
  description = "Next ASG CPU target utilization percentage."
  type        = number
  default     = 60
}

variable "asg_next_tags" {
  description = "Additional tags to apply to Next ASG instances."
  type        = map(string)
  default     = {}
}
