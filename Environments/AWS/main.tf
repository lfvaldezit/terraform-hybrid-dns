
module "security-group" {
  source = "../../modules/security-group"
  name   = "${var.name}-scp-grp"
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = true
  ingress_cidr_block     = ["0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0"]
  ingress_cidr_from_port = [-1, 53, 53, 443]
  ingress_cidr_to_port   = [-1, 53, 53, 443]
  ingress_cidr_protocol  = ["icmp", "udp", "tcp", "tcp"]

  create_egress_cidr    = true
  egress_cidr_block     = ["0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0"]
  egress_cidr_from_port = [-1, 53, 53, 443]
  egress_cidr_to_port   = [-1, 53, 53, 443]
  egress_cidr_protocol  = ["icmp", "udp", "tcp", "tcp"]


  common_tags = local.common_tags
}

module "vpc" {
  source                  = "../../modules/vpc"
  name                    = var.name
  cidr_block              = var.cidr_block
  subnets                 = var.subnets
  common_tags             = local.common_tags
  create_r53_in_endpoint  = true
  create_r53_out_endpoint = true
  target_domain_name      = var.target_domain_name
  r53_resolver_in_ip_1    = var.inbound_r53_resolver_ip_1
  r53_resolver_in_ip_2    = var.inbound_r53_resolver_ip_2
  target_ip_primary       = var.target_ip_primary
  target_ip_secondary     = var.target_ip_secondary
}

module "ec2-app" {
  source             = "../../modules/ec2"
  ec2_name           = "${var.name}-ec2-app"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  security_group_ids = [module.security-group.id]
  subnet_id          = module.vpc.private_subnet_ids[0]
  common_tags        = local.common_tags
}


module "peering" {
  source      = "../../modules/peering"
  name        = "${var.name}-peering-${var.target_vpc_id}"
  common_tags = local.common_tags

  # REQUESTER
  requester_vpc_id         = module.vpc.vpc_id
  requester_cidr_block     = module.vpc.vpc_cidr_block
  requester_route_table_id = module.vpc.route_table_id
  # TARGET
  target_vpc_id         = var.target_vpc_id
  target_cidr_block     = var.target_cidr_block
  target_route_table_id = var.target_route_table_id
}

module "route53-zone" {
  source       = "../../modules/route53-zone"
  domain_name  = var.domain_name
  vpc_id       = module.vpc.vpc_id
  record_name  = "app1.aws.example4life.org"
  record_value = module.ec2-app.private_ip
}
