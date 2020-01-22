resource "aws_service_discovery_service" "server" {
  name = var.server_name
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.client.id
    dns_records {
      ttl = 300
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "server" {
  name = var.server_name
  cluster = data.aws_ecs_cluster.howto_grpc.id
  task_definition = aws_ecs_task_definition.server.arn
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  launch_type = "FARGATE"
  desired_count = 1
  service_registries {
    registry_arn = aws_service_discovery_service.server.arn
  }
  network_configuration {
    subnets = [data.aws_subnet.private_a.id, data.aws_subnet.private_c.id]
    security_groups = [aws_security_group.instance.id]
    assign_public_ip = false
  }
}

resource "aws_ecs_task_definition" "server" {
  requires_compatibilities = ["FARGATE"]
  family = var.server_name
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  task_role_arn = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.task_exe.arn
  proxy_configuration {
    type = "APPMESH"
    container_name = "envoy"
    properties = {
      AppPorts         = "8080"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
  container_definitions = templatefile("${path.module}/task_def_server.json.tpl",{
    account_id = var.account_id,
    region = var.region,
    project_name = var.project_name,
    container_port = var.container_port,
    server_name = var.server_name,
    envoy_image = var.envoy_image
  })
}
