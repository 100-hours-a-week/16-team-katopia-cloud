variable "name" {
  description = "ASG name."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ASG."
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of instances."
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances."
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances."
  type        = number
}

variable "ami_id" {
  description = "AMI ID for instances."
  type        = string
}

variable "instance_type" {
  description = "Instance type."
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "Security group IDs for instances."
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data for instances (raw string)."
  type        = string
  default     = null
}

variable "target_group_arns" {
  description = "Target group ARNs to attach."
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Health check type (EC2 or ELB)."
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds."
  type        = number
  default     = 300
}

variable "tags" {
  description = "Common tags to apply to instances."
  type        = map(string)
  default     = {}
}

variable "cpu_target_utilization" {
  description = "Target CPU utilization percentage for ASG scaling."
  type        = number
  default     = 60
}
