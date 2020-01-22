provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "infra" {
  source = "./modules/infra"
}

module "app" {
  source = "./modules/app"
}

module "mesh" {
  source = "./modules/mesh"
}

variable "access_key" {}
variable "secret_key" {}
variable "region" {}