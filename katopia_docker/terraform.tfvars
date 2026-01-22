vpc_cidr_block = "11.0.0.0/16"
public_subnet_cidr_blocks = [
  "11.0.1.0/24",
  "11.0.2.0/24"
]
private_app_subnet_cidr_blocks = [
  "11.0.11.0/24",
  "11.0.12.0/24"
]
private_db_subnet_cidr_blocks = [
  "11.0.21.0/24",
  "11.0.22.0/24"
]
public_subnet_azs = [
  "ap-northeast-2a",
  "ap-northeast-2c"
]

security_group_name = "katopia-docker_docker"
spring_security_group_name = "katopia-docker-spring-sg"
next_security_group_name   = "katopia-docker-next-sg"
vpc_endpoint_security_group_name = "katopia-docker-vpce-sg"
vpc_endpoint_name_prefix = "katopia-docker-vpce"

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

ami_id        = "ami-03fd85ef2fae79c05"
instance_type = "t3.small"
key_name      = "community"

iam_role_name             = "katopia-docker-ec2-role"
iam_instance_profile_name = "katopia-docker-ec2-profile"
iam_managed_policy_arns = [
  "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
]

alb_name            = "katopia-docker-alb"
alb_certificate_arn = null

alb_target_groups = {
  spring = {
    name                 = "katopia-docker-spring-tg-v2"
    port                 = 8080
    protocol             = "HTTP"
    health_check_path    = "/actuator/health"
    health_check_matcher = "200"
  }
  next = {
    name                 = "katopia-docker-next-tg-v2"
    port                 = 3000
    protocol             = "HTTP"
    health_check_path    = "/"
    health_check_matcher = "200"
  }
}

alb_default_target_group_key = "next"

alb_path_rules = [
  {
    priority         = 10
    target_group_key = "spring"
    path_patterns    = ["/api*", "/login*", "/oauth2*"]
  }
]

asg_spring_name                     = "katopia-docker-spring-asg"
asg_spring_min_size                 = 1
asg_spring_max_size                 = 2
asg_spring_desired_capacity         = 2
asg_spring_target_group_key         = "spring"
asg_spring_health_check_type        = "ELB"
asg_spring_health_check_grace_period = 300
asg_spring_user_data                = null
asg_spring_ami_id                   = null
asg_spring_instance_type            = null
asg_spring_cpu_target_utilization   = 60

asg_next_name                        = "katopia-docker-next-asg"
asg_next_min_size                    = 1
asg_next_max_size                    = 2
asg_next_desired_capacity            = 2
asg_next_target_group_key            = "next"
asg_next_health_check_type           = "ELB"
asg_next_health_check_grace_period   = 300
asg_next_user_data                   = null
asg_next_ami_id                      = null
asg_next_instance_type               = null
asg_next_cpu_target_utilization      = 60
