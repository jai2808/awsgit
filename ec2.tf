resource "aws_vpc" "rhel8-vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "rhel8-vpc"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("D:/AWSCloud/oralogin.pem")
      host        = self.public_ip
    }

    inline = [
      "sudo yum update -y",
      "mkdir soft",
      "cd soft",
      "sudo yum install python3-pip",
      "pip3 install awscli",
      "mkdir -p /home/ec2-user/.aws",
      "echo '[default]' > /home/ec2-user/.aws/credentials",
      "aws configure set aws_access_key_id YOUR_ACCESS_KEY_ID",
      "aws configure set aws_secret_access_key YOUR_SECRET_ACCESS_KEY",
      "aws configure set region us-west-2",
      "echo '[default]' > /home/ec2-user/.aws/config",
      "echo 'region = us-west-2' >> /home/ec2-user/.aws/config",
      "echo 'output = json' >> /home/ec2-user/.aws/config",
      "aws s3 cp s3://orasoft-aws/21ai/oracle-database-preinstall-23ai-1.0-2.el9.x86_64.rpm /home/ec2-user/soft"
    ]
  }
}
