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

variable "private_registry_access_token" {
  type    = map
  default = {}
}

module "simple" {
  source = "../../"

  name = "simple-1"

  private_registry_access_token = var.private_registry_access_token
}

output "alb_hostname" {
  value = module.simple.alb_hostname
}

