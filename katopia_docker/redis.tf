module "redis_instance" {
  source = "./modules/compute"

  ami_id                 = var.redis_ami_id
  instance_type          = var.redis_instance_type != null ? var.redis_instance_type : var.instance_type
  subnet_id              = module.network.private_app_subnet_ids[0]
  vpc_security_group_ids = [module.redis_security.security_group_id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile_name
  name                   = var.redis_name
  tags                   = var.tags
}
