variable "region" {
  default = "us-west-2"
}

variable "account_id" {
  default = "151440741398"
}

variable "project_name" {
  default = "howto-grpc"
}

variable "client_name" {
  default = "color_client"
}

variable "server_name" {
  default = "color_server"
}

variable "sub_domain" {
  default = "local"
}

variable "envoy_image" {
  default = "840364872350.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.12.1.1-prod"
}

variable "container_port" {
  default = 8080
}