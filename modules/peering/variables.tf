variable "requester_vpc_id" {
    type = string
}

variable "target_vpc_id" {
  type = string
}

variable "name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "requester_cidr_block" {
  type = string
}

variable "requester_route_table_id" {
  type = string
}

variable "target_route_table_id" {
  type = string
}

variable "target_cidr_block" {
  type = string
}