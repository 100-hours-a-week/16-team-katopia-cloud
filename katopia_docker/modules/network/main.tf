resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "katopia-docker-vpc" })
}

locals {
  public_subnets      = { for idx, az in var.public_subnet_azs : az => var.public_subnet_cidr_blocks[idx] }
  private_app_subnets = { for idx, az in var.public_subnet_azs : az => var.private_app_subnet_cidr_blocks[idx] }
  private_db_subnets  = { for idx, az in var.public_subnet_azs : az => var.private_db_subnet_cidr_blocks[idx] }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "katopia-docker-igw" })
}

resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "katopia-docker-public-subnet-${each.key}" })
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = merge(var.tags, { Name = "katopia-docker-nat-eip-${each.key}" })
}

resource "aws_nat_gateway" "this" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.tags, { Name = "katopia-docker-nat-gw-${each.key}" })
}

resource "aws_subnet" "private_app" {
  for_each                = local.private_app_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "katopia-docker-private-app-subnet-${each.key}" })
}

resource "aws_subnet" "private_db" {
  for_each                = local.private_db_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "katopia-docker-private-db-subnet-${each.key}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "katopia-docker-public-rt" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table" "private_app" {
  for_each = aws_subnet.private_app
  vpc_id   = aws_vpc.this.id

  tags = merge(var.tags, { Name = "katopia-docker-private-app-rt-${each.key}" })
}

resource "aws_route_table" "private_db" {
  for_each = aws_subnet.private_db
  vpc_id   = aws_vpc.this.id

  tags = merge(var.tags, { Name = "katopia-docker-private-db-rt-${each.key}" })
}

resource "aws_route" "private_app_nat" {
  for_each               = aws_route_table.private_app
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route" "private_db_nat" {
  for_each               = aws_route_table.private_db
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  for_each       = aws_subnet.private_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app[each.key].id
}

resource "aws_route_table_association" "private_db" {
  for_each       = aws_subnet.private_db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db[each.key].id
}
