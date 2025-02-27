resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "rhel8-vpc1"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "rhel8-sub1"
  }

}