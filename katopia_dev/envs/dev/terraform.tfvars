vpc_cidr_block           = "10.0.0.0/16"
public_subnet_cidr_block = "10.0.1.0/24"
public_subnet_az         = "ap-northeast-2a"

security_group_name = "katopia_bigbang_dev"

security_group_ingress_rules = [
  {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    security_groups  = []
    prefix_list_ids  = []
    self             = false
  },
  {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    security_groups  = []
    prefix_list_ids  = []
    self             = false
  },
  {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    security_groups  = []
    prefix_list_ids  = []
    self             = false
  }
]

security_group_egress_rules = [
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

ami_id        = "ami-09847a9d9d71bd9f5"
instance_type = "t3.small"
key_name      = "katopia"
