# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

provider "random" {
  version = "~> 2.2"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_region" "current" {}

variable "environment" {
  type    = string
  default = "develop"
}

variable "config" {
  type = map(object({
    vpc_cidr_block = string
  }))
  default = {
    "develop"    = { vpc_cidr_block = "10.0.0.0/16" }
    "production" = { vpc_cidr_block = "10.1.0.0/16" }
    "serverless" = { vpc_cidr_block = "10.2.0.0/16" }
  }
}

