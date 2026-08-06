###############################################################################
# Private Route Table
###############################################################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt"
  }

}

###############################################################################
# Associate Private Subnets
###############################################################################

resource "aws_route_table_association" "private" {

  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private.id

}
