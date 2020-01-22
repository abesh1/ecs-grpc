resource "aws_security_group" "lb" {
  name = "${var.project_name}-lb"
  vpc_id = data.aws_vpc.howto_grpc.id
}

resource "aws_security_group_rule" "ingress_lb" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.lb.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "task" {
  name = "${var.project_name}-task"
  vpc_id = data.aws_vpc.howto_grpc.id
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [data.aws_vpc.howto_grpc.cidr_block]
  }
}

resource "aws_cloudwatch_log_group" "howto_grpc" {
  name = "${var.project_name}-log-group"
  retention_in_days = 30
}

resource "aws_iam_role" "task" {
  name = "task-role"
  assume_role_policy = data.aws_iam_policy_document.task_role.json
}

resource "aws_iam_role_policy_attachment" "task_cloud_watch" {
  policy_arn = data.aws_iam_policy.cloud_watch.arn
  role = aws_iam_role.task.name
}

resource "aws_iam_role_policy_attachment" "task_x_ray" {
  policy_arn = data.aws_iam_policy.x_ray.arn
  role = aws_iam_role.task.name
}

resource "aws_iam_role_policy_attachment" "task_app_mesh" {
  policy_arn = data.aws_iam_policy.app_mesh.arn
  role = aws_iam_role.task.name
}

resource "aws_iam_role" "task_exe" {
  name = "task-exe-role"
  assume_role_policy = data.aws_iam_policy_document.task_role.json
}

resource "aws_iam_role_policy_attachment" "task_exe_ec2" {
  policy_arn = data.aws_iam_policy.ec2.arn
  role = aws_iam_role.task_exe.name
}

resource "aws_iam_role_policy_attachment" "task_exe_cloud_watch" {
  policy_arn = data.aws_iam_policy.cloud_watch.arn
  role = aws_iam_role.task_exe.name
}

resource "aws_security_group" "instance" {
  vpc_id = data.aws_vpc.howto_grpc.id
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [data.aws_vpc.howto_grpc.cidr_block]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}