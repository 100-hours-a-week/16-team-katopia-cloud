module "security" {
  source = "./modules/security"

  vpc_id        = module.network.vpc_id
  name          = var.security_group_name
  ingress_rules = var.security_group_ingress_rules
  egress_rules  = var.security_group_egress_rules
  tags          = var.tags
}

module "spring_security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id
  name   = var.spring_security_group_name
  ingress_rules = [
    {
      description      = "Spring from ALB"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [module.security.security_group_id]
      prefix_list_ids  = []
      self             = false
    }
  ]
  egress_rules = [
    {
      description      = "Allow all egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]
  tags = var.tags
}

module "next_security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id
  name   = var.next_security_group_name
  ingress_rules = [
    {
      description      = "Next from ALB"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [module.security.security_group_id]
      prefix_list_ids  = []
      self             = false
    }
  ]
  egress_rules = [
    {
      description      = "Allow all egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]
  tags = var.tags
}

module "vpc_endpoint_security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id
  name   = var.vpc_endpoint_security_group_name
  ingress_rules = [
    {
      description      = "VPC endpoints HTTPS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [var.vpc_cidr_block]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]
  egress_rules = [
    {
      description      = "Allow all egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    }
  ]
  tags = var.tags
}
