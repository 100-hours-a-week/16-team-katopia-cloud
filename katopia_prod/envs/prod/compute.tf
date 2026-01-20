module "compute" {
  source = "../../modules/compute"

  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [module.security.security_group_id]
  key_name               = var.key_name
  tags                   = var.tags
}
