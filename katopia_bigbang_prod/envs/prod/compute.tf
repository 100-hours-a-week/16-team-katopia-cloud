module "compute" {
  source = "../../modules/compute"

  ami_id                 = "ami-02b10fd4e2e3f804d"
  instance_type          = var.instance_type
  root_volume_size       = var.root_volume_size
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [module.security.security_group_id]
  key_name               = var.key_name
  iam_instance_profile   = module.iam.instance_profile_name
  tags                   = var.tags
}
