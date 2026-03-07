resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "subnet" {
  for_each = var.subnet_details

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.role != "rds-az-2" ? "${var.default_region}a" : "${var.default_region}b"
  map_public_ip_on_launch = each.value.access == "public" ? true : false

  tags = {
    Name = "${each.key}-sub"
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet["public"].id

  tags = {
    Name = "NAT-gateway"
  }

  depends_on = [aws_internet_gateway.internet-gw]
}

resource "aws_route_table" "public-sub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name = "public-sub-route-table"
  }
}

resource "aws_route_table" "private-sub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "private-sub-route-table"
  }
}

resource "aws_route_table_association" "rt_association" {
  for_each = aws_subnet.subnet

  subnet_id      = each.value.id
  route_table_id = var.subnet_details[each.key].access == "public" ? aws_route_table.public-sub-rt.id : aws_route_table.private-sub-rt.id
}