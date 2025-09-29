output "ONPREM-DNS-1" {
  value = module.ec2-dns-1.private_ip
}

output "ONPREM-DNS-2" {
  value = module.ec2-dns-2.private_ip
}

output "ONPREM-RT_ID" {
  value = module.vpc.route_table_id
}

output "ONPREM-VPC_ID" {
  value = module.vpc.vpc_id
}

output "ONPREM-CIDR_BLOCK" {
  value = module.vpc.vpc_cidr_block
}