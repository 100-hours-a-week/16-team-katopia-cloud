module "alb" {
  source = "./modules/alb"

  name                     = var.alb_name
  vpc_id                   = module.network.vpc_id
  subnet_ids               = module.network.public_subnet_ids
  security_group_ids       = [module.security.security_group_id]
  certificate_arn          = var.alb_certificate_arn
  target_groups            = var.alb_target_groups
  default_target_group_key = var.alb_default_target_group_key
  path_rules               = var.alb_path_rules
  tags                     = var.tags
}
