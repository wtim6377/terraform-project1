resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DucksVPC"
  }
}
# Create subnets in two availability zones
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "DucksSubnet1-Public"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "DucksSubnet1-Public"
  }
}
resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "DucksSubnet1-Private"
  }
}
resource "aws_subnet" "subnet4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "DucksSubnet2-Private"
  }

}
resource "aws_subnet" "subnet5" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "DucksSubnet2-Data"
  }

}
resource "aws_subnet" "subnet6" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "DucksSubnet2-Data"
  }

}
# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Create a public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "DucksPublicRouteTable"
  }
}

# Create a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "DucksPrivateRouteTable"
  }
}

# Associate public route table with public subnets
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate private route table with private subnets
resource "aws_route_table_association" "private_subnet3_association" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet4_association" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.private_route_table.id
}
# Associate private route table with Data Subnets
resource "aws_route_table_association" "data_subnet5_association" {
  subnet_id      = aws_subnet.subnet5.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "data_subnet6_association" {
  subnet_id      = aws_subnet.subnet6.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create a NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet1.id

  tags = {
    Name = "DucksNATGateway"
  }
}

# Create an EIP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "NATGatewayEIP"
  }
}

# Create a route in the private route table for the NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
# Create a route in the private route table for the RDS subnets
resource "aws_route" "private_to_rds_route1" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = aws_subnet.subnet5.cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route" "private_to_rds_route2" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = aws_subnet.subnet6.cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"
}