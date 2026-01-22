output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "Public subnet ID."
  value       = aws_subnet.public.id
}

output "igw_id" {
  description = "Internet gateway ID."
  value       = aws_internet_gateway.this.id
}
