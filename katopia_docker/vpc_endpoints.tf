data "aws_region" "current" {}

locals {
  vpc_endpoint_interface_services = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "ecr.api",
    "ecr.dkr"
  ]
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.vpc_endpoint_interface_services)

  vpc_id              = module.network.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.network.private_app_subnet_ids
  security_group_ids  = [module.vpc_endpoint_security.security_group_id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.vpc_endpoint_name_prefix}-${replace(each.value, ".", "-")}"
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.network.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(module.network.private_app_route_table_ids, module.network.private_db_route_table_ids)

  tags = merge(var.tags, { Name = "${var.vpc_endpoint_name_prefix}-s3" })
}
