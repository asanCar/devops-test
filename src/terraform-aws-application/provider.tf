# Configure Cloud provider
provider "aws" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "test"
    key            = "${var.aws_region}/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "terraform_locks"
  }
}
