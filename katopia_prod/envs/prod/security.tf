module "security" {
  source = "../../modules/security"

  vpc_id        = module.network.vpc_id
  name          = var.security_group_name
  ingress_rules = var.security_group_ingress_rules
  egress_rules  = var.security_group_egress_rules
  tags          = var.tags
}
