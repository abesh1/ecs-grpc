resource "aws_cloudformation_stack" "router" {
  name = "router-stack"
  template_body = file("${path.module}/router.yaml")
  depends_on = [aws_cloudformation_stack.node_server]
  parameters = {
    MeshName = aws_appmesh_mesh.mesh.name
    NodeName = var.server_name
    ServiceName = var.service_name
    MethodName = var.method_name
    Port = var.container_port
  }
}