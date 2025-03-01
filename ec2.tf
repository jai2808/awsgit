resource "aws_instance" "foo" {

  ami                         = var.ami # us-west-2
  instance_type               = var.instancetype
  subnet_id                   = var.subnetid
  associate_public_ip_address = true
  key_name                    = var.keyname
  security_groups             = ["sg-06702b76159fecc7d"]
  tags = {
    Name         = var.instance_name
    "costcenter" = "23444"
  }
}