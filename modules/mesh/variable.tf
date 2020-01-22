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

variable "container_port" {
  default = 8080
}

variable "service_name" {
  default = "color.ColorService"
}

variable "method_name" {
  default = "GetColor"
}
