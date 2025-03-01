resource "aws_instance" "foo" {
  ami           = "ami-0041f866474ace6ea" # us-west-2
  instance_type = "t2.micro"
  subnet_id = "subnet-0704c036c03980b2d"
  tags = {
      Name = "TF-Instance"
  }
}