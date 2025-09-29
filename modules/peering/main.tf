resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.target_vpc_id
  auto_accept   = true
  tags = merge({Name = var.name}, var.common_tags)
}

resource "aws_route" "requester" {
  route_table_id         = var.requester_route_table_id
  destination_cidr_block = var.target_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "target" {
  route_table_id         = var.target_route_table_id
  destination_cidr_block = var.requester_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}