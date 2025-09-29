name                 = "vpc-onprem"
cidr_block           = "10.192.0.0/16"
private_subnet_cidrs = ["10.192.1.0/24", "10.192.2.0/24"]


availability_zones = ["us-east-1a", "us-east-1b"]
ami_id             = "ami-08982f1c5bf93d976"
instance_type      = "t2.micro"

subnets = [{ name = "onprem-private-1a", cidr_block = "10.192.1.0/24", az = "us-east-1a" },
{ name = "onprem-private-1b", cidr_block = "10.192.2.0/24", az = "us-east-1b" }]

inbound_r53_resolver_ip_1 = "192.168.1.200"
inbound_r53_resolver_ip_2 = "192.168.2.200"