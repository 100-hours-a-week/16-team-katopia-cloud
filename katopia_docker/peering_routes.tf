data "aws_vpc_peering_connection" "existing" {
  count = var.existing_vpc_peering_connection_id != null ? 1 : 0
  id    = var.existing_vpc_peering_connection_id
}

locals {
  private_db_route_table_by_az = zipmap(var.public_subnet_azs, module.network.private_db_route_table_ids)
}

resource "aws_route" "cdc_private_db_to_peer_vpc" {
  count = var.existing_vpc_peering_connection_id != null && contains(var.public_subnet_azs, var.cdc_private_db_route_az) ? 1 : 0

  route_table_id            = local.private_db_route_table_by_az[var.cdc_private_db_route_az]
  destination_cidr_block    = var.peer_vpc_cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.existing[0].id
}
