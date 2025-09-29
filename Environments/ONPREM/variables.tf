variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}


variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnets" {
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
}