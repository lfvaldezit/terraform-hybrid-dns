output "vpc_id" {
  value = aws_vpc.this.id
}

# output "private_subnet_ids" {
#   value = aws_subnet.this[*].id
# }

output "private_subnet_ids" {
  value = [for s in aws_subnet.this : s.id]
}

output "route_table_id" {
  value = aws_route_table.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

# output "r53_resolver_endpoint_in" {
#   value = aws_route53_resolver_endpoint.in.ip_address
# }