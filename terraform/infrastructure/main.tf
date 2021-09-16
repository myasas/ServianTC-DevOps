terraform {
  required_version = "~> 0.0"
  backend "s3" {}

required_providers {
  

    aws= {
      source  = "aws"
      version = "~> 3.0"
    }
  }
}
