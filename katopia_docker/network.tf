module "network" {
  source = "./modules/network"

  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  private_app_subnet_cidr_blocks = var.private_app_subnet_cidr_blocks
  private_db_subnet_cidr_blocks  = var.private_db_subnet_cidr_blocks
  public_subnet_azs         = var.public_subnet_azs
  tags                      = var.tags
}
