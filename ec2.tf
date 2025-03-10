resource "aws_vpc" "rhel8-vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "rhel8-vpc"
    "cost"= "2123"
  }
}

resource "aws_subnet" "rhel8-subnet" {
  vpc_id                          = aws_vpc.rhel8-vpc.id
  cidr_block                      = "10.0.0.0/24"
  assign_ipv6_address_on_creation = false

  tags = {
    Name = "rhel8-subnet"
  }
}


resource "aws_internet_gateway" "rhel8-igw" {
  vpc_id = aws_vpc.rhel8-vpc.id
  tags = {
    Name = "rhel8-igw"
  }
}

resource "aws_route_table" "rhel8-rt" {
  vpc_id = aws_vpc.rhel8-vpc.id

  tags = {
    Name = "rhel8-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rhel8-igw.id
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

resource "aws_network_acl" "rhel_acl" {
  vpc_id = aws_vpc.rhel8-vpc.id
  tags = {
    Name = "rhel_acl"
  }
}

resource "aws_network_acl_rule" "allow_all_inbound" {
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  network_acl_id = aws_network_acl.rhel_acl.id
}


resource "aws_network_acl_rule" "allow_all_outboud" {
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  network_acl_id = aws_network_acl.rhel_acl.id
}


resource "aws_security_group" "rhel_sg" {
  name        = "rhel_sg"
  description = "Custom Access to EC2"
  vpc_id      = aws_vpc.rhel8-vpc.id

  tags = {
    Name = "rhel_sg"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rhel_sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  description       = "HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rhel_sg.id
}

resource "aws_security_group_rule" "jenkins" {
  type              = "ingress"
  description       = "Jenkis"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rhel_sg.id
}


resource "aws_security_group_rule" "egressall" {
  type              = "egress"
  description       = "All outboud"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rhel_sg.id
}

resource "aws_instance" "foo" {

  ami                         = var.ami # us-west-2
  instance_type               = var.instancetype
  subnet_id                   = aws_subnet.rhel8-subnet.id
  associate_public_ip_address = true
  key_name                    = var.keyname
  security_groups             = [aws_security_group.rhel_sg.id]
  tags = {
    Name         = var.instance_name
    "costcenter" = "23444"
  }
}
