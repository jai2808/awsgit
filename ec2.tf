resource "aws_vpc" "rhel8-vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "rhel8-vpc"
  }
}

resource "aws_subnet" "rhel8-subnet" {
  vpc_id     = aws_vpc.rhel8-vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "rhel8-subnet"
  }
}


resource "aws_internet_gateway" "rhel8-rt" {
  vpc_id = aws_vpc.rhel8-vpc.id
  tags = {
    Name = "rhel8-igw"
  }
}

resource "aws_route_table" "rhel8-rt" {
  vpc_id = aws_vpc.rhel8-vpc.id

  tags = {
    name = "rhel8-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rhel8-rt.id
  }

  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "rt_asso" {
  subnet_id      = aws_subnet.rhel8-subnet.id
  route_table_id = aws_route_table.rhel8-rt.id
}
