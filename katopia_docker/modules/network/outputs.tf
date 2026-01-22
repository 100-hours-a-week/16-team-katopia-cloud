output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "First public subnet ID."
  value       = aws_subnet.public[var.public_subnet_azs[0]].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = [for az in var.public_subnet_azs : aws_subnet.public[az].id]
}

output "private_app_subnet_ids" {
  description = "Private app subnet IDs."
  value       = [for az in var.public_subnet_azs : aws_subnet.private_app[az].id]
}

output "private_db_subnet_ids" {
  description = "Private db subnet IDs."
  value       = [for az in var.public_subnet_azs : aws_subnet.private_db[az].id]
}

output "private_app_route_table_ids" {
  description = "Private app route table IDs."
  value       = [for az in var.public_subnet_azs : aws_route_table.private_app[az].id]
}

output "private_db_route_table_ids" {
  description = "Private db route table IDs."
  value       = [for az in var.public_subnet_azs : aws_route_table.private_db[az].id]
}

output "igw_id" {
  description = "Internet gateway ID."
  value       = aws_internet_gateway.this.id
}
