variable "project_name" {
  default = "howto-grpc"
}

variable "key_pair" {
  default = "dot_nagisa_abe"
}

variable "client_name" {
  default = "color_client"
}

variable "server_name" {
  default = "color_server"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  default = "10.0.0.0/19"
}

variable "public_subnet_2_cidr" {
  default = "10.0.32.0/19"
}

variable "private_subnet_1_cidr" {
  default = "10.0.64.0/19"
}

variable "private_subnet_2_cidr" {
  default = "10.0.96.0/19"
}