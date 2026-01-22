module "iam" {
  source = "./modules/iam"

  role_name             = var.iam_role_name
  instance_profile_name = var.iam_instance_profile_name
  managed_policy_arns   = var.iam_managed_policy_arns
  inline_policy_name    = var.iam_inline_policy_name
  inline_policy_json    = var.iam_inline_policy_json
  tags                  = var.tags
}
