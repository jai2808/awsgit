variable "instance_name" {
    description = "This is default instance name"
    type = string
    default = "rhel8"
}

variable "ami" {
    description = "This is the AMI Image"
    type = string
    default = "ami-0041f866474ace6ea"
}

variable "instancetype" {
    description = "This is the AMI Instance type"
    type = string
    default = "t2.micro"
}


variable "subnetid" {
    description = "This is the Subnet ID"
    type = string
    default = "subnet-0704c036c03980b2d"
}