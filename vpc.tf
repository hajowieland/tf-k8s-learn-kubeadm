resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = var.tags
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = var.tags
}


# --------------------------------------------------------------------------
# Private Subnets
# --------------------------------------------------------------------------
resource "aws_eip" "eip" {
  vpc = true

  tags = var.tags
}


resource "aws_subnet" "private" {
  count = var.number_azs

  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, (0 * var.number_azs) + count.index)

  tags = merge(var.tags, map("Name", "private-${data.aws_availability_zones.available.names[count.index]}"))
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = var.tags

  lifecycle {
    ignore_changes = [route]
  }
}


resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count = var.number_azs

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}



# --------------------------------------------------------------------------
# NAT Gateways
# --------------------------------------------------------------------------
resource "aws_nat_gateway" "natgw" {

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.0.id

  tags = var.tags
}


# --------------------------------------------------------------------------
# Public Subnets
# --------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = var.number_azs

  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc.id
  // For every new subnet group, increment the left side of the var.number_azs multiplicator
  cidr_block = cidrsubnet(var.vpc_cidr, 4, 1 + (1 * var.number_azs) + count.index)

  tags = merge(var.tags, map("Name", "public-${data.aws_availability_zones.available.names[count.index]}"))
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = var.tags

  lifecycle {
    ignore_changes = [route]
  }
}


resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  timeouts {
    create = "5m"
  }
}


resource "aws_route_table_association" "public" {
  count = var.number_azs

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
