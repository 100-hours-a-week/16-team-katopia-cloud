module "asg_spring" {
  source = "./modules/asg"

  name                     = var.asg_spring_name
  subnet_ids               = module.network.private_app_subnet_ids
  min_size                 = var.asg_spring_min_size
  max_size                 = var.asg_spring_max_size
  desired_capacity         = var.asg_spring_desired_capacity
  ami_id                   = var.asg_spring_ami_id != null ? var.asg_spring_ami_id : var.ami_id
  instance_type            = var.asg_spring_instance_type != null ? var.asg_spring_instance_type : var.instance_type
  key_name                 = var.key_name
  vpc_security_group_ids   = [module.spring_security.security_group_id]
  iam_instance_profile_name = module.iam.instance_profile_name
  user_data                = var.asg_spring_user_data
  target_group_arns        = [module.alb.target_group_arns[var.asg_spring_target_group_key]]
  health_check_type        = var.asg_spring_health_check_type
  health_check_grace_period = var.asg_spring_health_check_grace_period
  cpu_target_utilization   = var.asg_spring_cpu_target_utilization
  tags                     = var.tags
}

module "asg_next" {
  source = "./modules/asg"

  name                     = var.asg_next_name
  subnet_ids               = module.network.private_app_subnet_ids
  min_size                 = var.asg_next_min_size
  max_size                 = var.asg_next_max_size
  desired_capacity         = var.asg_next_desired_capacity
  ami_id                   = var.asg_next_ami_id != null ? var.asg_next_ami_id : var.ami_id
  instance_type            = var.asg_next_instance_type != null ? var.asg_next_instance_type : var.instance_type
  key_name                 = var.key_name
  vpc_security_group_ids   = [module.next_security.security_group_id]
  iam_instance_profile_name = module.iam.instance_profile_name
  user_data                = var.asg_next_user_data
  target_group_arns        = [module.alb.target_group_arns[var.asg_next_target_group_key]]
  health_check_type        = var.asg_next_health_check_type
  health_check_grace_period = var.asg_next_health_check_grace_period
  cpu_target_utilization   = var.asg_next_cpu_target_utilization
  tags                     = var.tags
}
