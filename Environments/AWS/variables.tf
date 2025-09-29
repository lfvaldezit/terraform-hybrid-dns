variable "name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "target_vpc_id" {
  type = string
}

variable "target_cidr_block" {
  type = string
}

variable "target_route_table_id" {
  type = string
}

variable "inbound_r53_resolver_ip_1" {
  type = string
}

variable "inbound_r53_resolver_ip_2" {
  type = string
}

variable "target_domain_name" {
  type = string
}


variable "target_ip_primary" {
  type = string
}

variable "target_ip_secondary" {
  type = string
}

variable "subnets" {
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
}