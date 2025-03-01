resource "aws_instance" "foo" {

  ami           = var.ami # us-west-2
  instance_type = var.instancetype
  subnet_id = var.subnetid
  tags = {
      Name = var.instance_name
  }
}