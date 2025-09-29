data "aws_region" "this" {}

# --------------- VPC & Subnet ----------------- #

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge({Name = var.name}, var.common_tags)
}

resource "aws_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  tags = merge({Name = each.value.name}, var.common_tags)
}

# --------------- Route Table ----------------- #

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this
  subnet_id      = each.value.id
  route_table_id = aws_route_table.this.id
}


# --------------- Endpoints for SSM ----------------- #

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

    egress {
    from_port       = 53
    to_port         = 53
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

    egress {
    from_port       = 53
    to_port         = 53
    protocol        = "udp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

    ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

    ingress {
    from_port       = 53    
    to_port         = 53
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

    ingress {
    from_port       = 53    
    to_port         = 53
    protocol        = "udp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_vpc_endpoint" "aws-ssm-int-endpoint" {
  vpc_id =  aws_vpc.this.id
  subnet_ids = [for subnet in aws_subnet.this : subnet.id]
  service_name      = "com.amazonaws.${data.aws_region.this.region}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.this.id ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "aws-ssm-ec2-messages" {
  vpc_id =  aws_vpc.this.id
  subnet_ids = [for subnet in aws_subnet.this : subnet.id]
  service_name      = "com.amazonaws.${data.aws_region.this.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.this.id ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "aws-ssm-ssm-messages" {
  vpc_id =  aws_vpc.this.id
  subnet_ids = [for subnet in aws_subnet.this : subnet.id]
  service_name      = "com.amazonaws.${data.aws_region.this.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.this.id ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onprems3endpoint" {
  vpc_id          = aws_vpc.this.id
  route_table_ids = [aws_route_table.this.id]
  service_name    = "com.amazonaws.${data.aws_region.this.region}.s3"
}

# --------------- Route53 Resolver ----------------- #

resource "aws_route53_resolver_endpoint" "in" { 
  count = var.create_r53_in_endpoint ? 1 : 0

  name                   = var.name
  direction              = "INBOUND"
  resolver_endpoint_type = "IPV4"

  security_group_ids = [ aws_security_group.this.id]

  ip_address {
    subnet_id = values(aws_subnet.this)[0].id
    ip = var.r53_resolver_in_ip_1
  }

  ip_address {
    subnet_id = values(aws_subnet.this)[1].id
    ip        = var.r53_resolver_in_ip_2
  }

  protocols = ["Do53", "DoH"]

  tags = merge({Name = "${var.name}-r53-in"}, var.common_tags)
}

resource "aws_route53_resolver_endpoint" "out" {
  count = var.create_r53_out_endpoint ? 1 : 0

  name                   = var.name
  direction              = "OUTBOUND"
  resolver_endpoint_type = "IPV4"

  security_group_ids = [ aws_security_group.this.id]

  ip_address {
    subnet_id = values(aws_subnet.this)[0].id
    #ip = var.r53_resolver_out_ip_1
  }

  ip_address {
    subnet_id = values(aws_subnet.this)[1].id
    #ip        = var.r53_resolver_out_ip_2
  }

  protocols = ["Do53", "DoH"]

  tags = merge({Name = "${var.name}-r53-out"}, var.common_tags)
}

resource "aws_route53_resolver_rule" "this" {
  count = var.create_r53_out_endpoint ? 1 : 0
  domain_name = var.target_domain_name
  name = var.target_domain_name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.out[0].id

  target_ip {
    ip = var.target_ip_primary
  }

   target_ip {
    ip = var.target_ip_secondary
  }

  tags = merge({Name = "${var.name}-${var.target_domain_name}"}, var.common_tags)
}
