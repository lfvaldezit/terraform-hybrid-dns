
# module "vpc" {
#   source               = "../../modules/vpc"
#   name                 = "vpc-test"
#   cidr_block           = "10.10.0.0/16"
#   private_subnet_cidrs = ["10.10.100.0/24", "10.10.100.0/24"]
#   availability_zones   = ["us-east-1a","us-east-1b"]
#   common_tags          = {
#     Owner       = "demo"
#     Environment = "dev"
#     ManagedBy   = "Terraform"
#   }
#   create_r53_in_endpoint = true
#   create_r53_out_endpoint = false
#   ip_addresses_inbound =[module.v, {}] 
# }

# module "r53" {
#     source = "../../modules/route53-zone"
#     domain_name = "example.com"
#     record_name = "web.example.com"
#     record_value = "1.1.1.1"
#     vpc_id = module.vpc.vpc_id
# }