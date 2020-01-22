data "aws_vpc" "howto_grpc" {
  state = "available"
  filter {
    name = "tag:Name"
    values = [var.project_name]
  }
}

data "aws_subnet" "public_a" {
  vpc_id = data.aws_vpc.howto_grpc.id
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-pub-a"]
  }
}

data "aws_subnet" "public_c" {
  vpc_id = data.aws_vpc.howto_grpc.id
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-pub-c"]
  }
}

data "aws_subnet" "private_a" {
  vpc_id = data.aws_vpc.howto_grpc.id
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-pri-a"]
  }
}

data "aws_subnet" "private_c" {
  vpc_id = data.aws_vpc.howto_grpc.id
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-pri-c"]
  }
}

data "aws_iam_policy_document" "task_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ec2" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "cloud_watch" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

data "aws_iam_policy" "x_ray" {
  arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

data "aws_iam_policy" "app_mesh" {
  arn = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
}

data "aws_ecs_cluster" "howto_grpc" {
  cluster_name = var.project_name
}