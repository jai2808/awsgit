resource "aws_instance" "foo" {

  ami           = var.ami # us-west-2
  instance_type = var.instancetype
  subnet_id = var.subnetid
  count =  1
  associate_public_ip_address = true
  key_name = var.keyname
  tags = {
      Name = var.instance_name
      "costcenter" = "23444"
  }
}