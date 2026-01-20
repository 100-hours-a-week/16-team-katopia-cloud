module "network" {
  source = "../../modules/network"

  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  public_subnet_az         = var.public_subnet_az
  tags                     = var.tags
}
