resource "aws_appmesh_virtual_service" "howto-grpc" {
  mesh_name = aws_appmesh_mesh.mesh.id
  name = "${var.server_name}.${var.project_name}.${var.sub_domain}"
  depends_on = [aws_cloudformation_stack.router]
  spec {
    provider {
      virtual_router {
        virtual_router_name = "virtual-router"
      }
    }
  }
}