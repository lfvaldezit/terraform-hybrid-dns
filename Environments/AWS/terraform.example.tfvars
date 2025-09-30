name       = "vpc-aws"
cidr_block = "192.168.0.0/16"

subnets = [{ name = "aws-private-1a", cidr_block = "192.168.1.0/24", az = "us-east-1a" },
{ name = "aws-private-1b", cidr_block = "192.168.2.0/24", az = "us-east-1b" }]

ami_id        = "ami-08982f1c5bf93d976"
instance_type = "t2.micro"

domain_name = "aws.example4life.org"

inbound_r53_resolver_ip_1 = "192.168.1.200"
inbound_r53_resolver_ip_2 = "192.168.2.200"

# --------------- OUTPUT ONPREM INFRA ----------------- #

target_domain_name    = "onprem.example4life.org"
target_vpc_id         = ""         # ONPREM-VPC_ID
target_cidr_block     = ""         # ONPREM-CIDR_BLOCK
target_route_table_id = ""         # ONPREM-RT_ID
target_ip_primary     = ""         # ONPREM-DNS-1
target_ip_secondary   = ""         # ONPREM-DNS-2


