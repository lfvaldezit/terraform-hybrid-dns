
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
  create_r53_in_endpoint  = false
  create_r53_out_endpoint = false
}

module "ec2-dns-1" {
  source             = "../../modules/ec2"
  ec2_name           = "${var.name}-ec2-dns-1"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  security_group_ids = [module.security-group.id]
  subnet_id          = module.vpc.private_subnet_ids[0]
  common_tags        = local.common_tags
  user_data          = <<-EOF
                      #!/bin/bash -xe
                      sudo yum update -y
                      sudo yum install bind bind-utils -y
                      cat <<EON > /etc/named.conf
                      options {
                        directory	"/var/named";
                        dump-file	"/var/named/data/cache_dump.db";
                        statistics-file "/var/named/data/named_stats.txt";
                        memstatistics-file "/var/named/data/named_mem_stats.txt";
                        allow-query { any; };
                        recursion yes;
                        forward first;
                        forwarders {
                          192.168.10.2;
                        };
                        dnssec-validation yes;
                        /* Path to ISC DLV key */
                        bindkeys-file "/etc/named.iscdlv.key";
                        managed-keys-directory "/var/named/dynamic";
                      };
                      zone "onprem.example4life.org" IN {
                          type master;
                          file "onprem.example4life.org.zone";
                          allow-update { none; };
                      };
                      zone "aws.example4life.org" {
                      type forward;
                      forward only;
                      forwarders { ${var.inbound_r53_resolver_ip_1}; ${var.inbound_r53_resolver_ip_2}; };
                      };
                      EON
                      cat <<EOD > /var/named/onprem.example4life.org.zone
                      \$TTL 86400
                      @   IN  SOA     ns1.mydomain.com. root.mydomain.com. (
                              2013042201  ;Serial
                              3600        ;Refresh
                              1800        ;Retry
                              604800      ;Expire
                              86400       ;Minimum TTL
                      )
                      ; Specify our two nameservers
                          IN	NS		dnsA.onprem.example4life.org.
                          IN	NS		dnsB.onprem.example4life.org.
                      ; Resolve nameserver hostnames to IP, replace with your two droplet IP addresses.
                      dnsA		IN	A		1.1.1.1
                      dnsB	  IN	A		8.8.8.8

                      ; Define hostname -> IP pairs which you wish to resolve
                      @		  IN	A		${module.ec2-app.private_ip}
                      app		IN	A	  ${module.ec2-app.private_ip}
                      EOD
                      service named restart
                      chkconfig named on
                    EOF
}

module "ec2-dns-2" {
  source             = "../../modules/ec2"
  ec2_name           = "${var.name}-ec2-dns-2"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  security_group_ids = [module.security-group.id]
  subnet_id          = module.vpc.private_subnet_ids[1]
  common_tags        = local.common_tags
  user_data          = <<-EOF
                      #!/bin/bash -xe
                      sudo yum update -y
                      sudo yum install bind bind-utils -y
                      cat <<EON > /etc/named.conf
                      options {
                        directory	"/var/named";
                        dump-file	"/var/named/data/cache_dump.db";
                        statistics-file "/var/named/data/named_stats.txt";
                        memstatistics-file "/var/named/data/named_mem_stats.txt";
                        allow-query { any; };
                        recursion yes;
                        forward first;
                        forwarders {
                          192.168.10.2;
                        };
                        dnssec-validation yes;
                        /* Path to ISC DLV key */
                        bindkeys-file "/etc/named.iscdlv.key";
                        managed-keys-directory "/var/named/dynamic";
                      };
                      zone "onprem.example4life.org" IN {
                          type master;
                          file "onprem.example4life.org.zone";
                          allow-update { none; };
                      };
                      zone "aws.example4life.org" {
                      type forward;
                      forward only;
                      forwarders { ${var.inbound_r53_resolver_ip_1}; ${var.inbound_r53_resolver_ip_2}; };
                      };
                      EON
                      cat <<EOD > /var/named/onprem.example4life.org.zone
                      \$TTL 86400
                      @   IN  SOA     ns1.mydomain.com. root.mydomain.com. (
                              2013042201  ;Serial
                              3600        ;Refresh
                              1800        ;Retry
                              604800      ;Expire
                              86400       ;Minimum TTL
                      )
                      ; Specify our two nameservers
                          IN	NS		dnsA.onprem.example4life.org.
                          IN	NS		dnsB.onprem.example4life.org.
                      ; Resolve nameserver hostnames to IP, replace with your two droplet IP addresses.
                      dnsA		IN	A		1.1.1.1
                      dnsB	  IN	A		8.8.8.8

                      ; Define hostname -> IP pairs which you wish to resolve
                      @		  IN	A		${module.ec2-app.private_ip}
                      app		IN	A	  ${module.ec2-app.private_ip}
                      EOD
                      service named restart
                      chkconfig named on
                    EOF
}

module "ec2-app" {
  source             = "../../modules/ec2"
  ec2_name           = "${var.name}-ec2-app"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  security_group_ids = [module.security-group.id]
  subnet_id          = module.vpc.private_subnet_ids[1]
  common_tags        = local.common_tags
}

