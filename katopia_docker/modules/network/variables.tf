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
