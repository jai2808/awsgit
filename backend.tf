backend "s3" {
    bucket         	   = "jai2808-terraform-state"
    key              	   = "state/terraform.tfstate"
    region         	   = "us-east-2"
  }