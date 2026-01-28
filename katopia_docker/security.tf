module "alb_security" {
  source = "./modules/security"

  vpc_id        = module.network.vpc_id
  name          = var.alb_security_group_name
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
      description      = "Spring 8080 from ALB"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [module.alb_security.security_group_id]
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "Spring 9100"
      from_port        = 9100
      to_port          = 9100
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
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

module "next_security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id
  name   = var.next_security_group_name
  ingress_rules = [
    {
      description      = "Next 3000 from ALB"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [module.alb_security.security_group_id]
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "Next 9100"
      from_port        = 9100
      to_port          = 9100
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
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

module "monitoring_security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id
  name   = var.monitoring_security_group_name
  ingress_rules = [
    {
      description      = "Monitoring SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "Monitoring 3000"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "Monitoring 9090"
      from_port        = 9090
      to_port          = 9090
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "Monitoring 3100"
      from_port        = 3100
      to_port          = 3100
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
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
