resource "aws_appmesh_virtual_node" "client" {
  mesh_name = aws_appmesh_mesh.mesh.name
  name = var.client_name
  spec {
    backend {
      virtual_service {
        virtual_service_name = aws_appmesh_virtual_service.howto-grpc.name
      }
    }
    listener {
      port_mapping {
        port = var.container_port
        protocol = "http"
      }
    }
    service_discovery {
      aws_cloud_map {
        namespace_name = "${var.project_name}.${var.sub_domain}"
        service_name = var.client_name
      }
    }
  }
}

resource "aws_cloudformation_stack" "node_server" {
  name = "node-server-stack"
  template_body = file("${path.module}/node_server.yaml")
  parameters = {
    MeshName = aws_appmesh_mesh.mesh.name
    NodeName = var.server_name
    Port = var.container_port
    ProjectName = var.project_name
    SubDomain = var.sub_domain
  }
}

