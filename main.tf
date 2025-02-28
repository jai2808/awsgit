provider "aws" {
    region = "us-east-2"  
}

resource "aws_instance" "foo" {
  ami           = "ami-0041f866474ace6ea" # us-west-2
  instance_type = "t2.micro"
  tags = {
      Name = "TF-Instance"
  }
}