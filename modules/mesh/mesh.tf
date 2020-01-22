resource "aws_appmesh_mesh" "mesh" {
  name = "${var.project_name}-mesh"
}