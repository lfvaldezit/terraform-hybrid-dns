variable "name" {
  description = "Name for all resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type = map(string)
  }

  variable "create_r53_in_endpoint" {
    description = "Controls if R53 IN resolver should be created"
    type = bool
  }

    variable "create_r53_out_endpoint" {
    description = "Controls if R53 OUT resolver should be created"
    type = bool
  }

  variable "r53_resolver_in_ip_1" {
    description = "R53 IN resolver IP 1"
    type = string
    default = "null"
  }

  variable "r53_resolver_in_ip_2" {
        description = "R53 IN resolver IP 2"
    type = string
    default = "null"
  }

  variable "target_domain_name" {
    description = "Target domain name"
    type = string
    default = ""
  }

  variable "target_ip_primary" {
    description = "Target IP primary"
    type = string
    default = "null"
  }

  variable "target_ip_secondary" {
      description = "Target IP secondary"
    type = string
    default = "null"
  }


variable "subnets" {
  description = "List of subnets"
  type = list(object({
    name                  = string
    cidr_block            = string
    az                    = string
  }))
}