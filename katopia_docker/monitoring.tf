module "monitoring_instance" {
  source = "./modules/compute"

  ami_id                 = var.monitoring_ami_id
  instance_type          = var.monitoring_instance_type != null ? var.monitoring_instance_type : var.instance_type
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [module.monitoring_security.security_group_id]
  key_name               = var.key_name
  iam_instance_profile   = var.monitoring_iam_instance_profile_name
  name                   = var.monitoring_name
  tags                   = var.tags
}
