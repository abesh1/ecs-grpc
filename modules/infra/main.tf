data aws_ssm_parameter awsec2_ami {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_vpc" "howto_grpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.project_name
  }
}

resource "aws_internet_gateway" "howto_grpc" {
  vpc_id = aws_vpc.howto_grpc.id
  tags = {
    Name = var.project_name
  }
}

resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.howto_grpc.id
  cidr_block = var.public_subnet_1_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"
  tags = {
    Name = "${var.project_name}-pub-a"
    Type = "public"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.howto_grpc.id
  cidr_block = var.public_subnet_2_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-west-2c"
  tags = {
    Name = "${var.project_name}-pub-c"
    Type = "public"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.howto_grpc.id
  cidr_block = var.private_subnet_1_cidr
  map_public_ip_on_launch = false
  availability_zone = "us-west-2a"
  tags = {
    Name = "${var.project_name}-pri-a"
    Type = "ptivate"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.howto_grpc.id
  cidr_block = var.private_subnet_2_cidr
  map_public_ip_on_launch = false
  availability_zone = "us-west-2c"
  tags = {
    Name = "${var.project_name}-pri-c"
    Type = "ptivate"
  }
}

resource "aws_eip" "nat_gateway_1" {
  vpc = true
  depends_on = [aws_internet_gateway.howto_grpc]
}

resource "aws_eip" "nat_gateway_2" {
  vpc = true
  depends_on = [aws_internet_gateway.howto_grpc]
}

resource "aws_nat_gateway" "howto_grpc_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.public1.id
  depends_on = [aws_internet_gateway.howto_grpc]
}

resource "aws_nat_gateway" "howto_grpc_2" {
  allocation_id = aws_eip.nat_gateway_2.id
  subnet_id = aws_subnet.public2.id
  depends_on = [aws_internet_gateway.howto_grpc]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.howto_grpc.id
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.howto_grpc.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public1" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public1.id
}

resource "aws_route_table_association" "public2" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public2.id
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.howto_grpc.id
}

resource "aws_route" "private1" {
  route_table_id = aws_route_table.private1.id
  nat_gateway_id = aws_nat_gateway.howto_grpc_1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private1"  {
  route_table_id = aws_route_table.private1.id
  subnet_id = aws_subnet.private1.id
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.howto_grpc.id
}

resource "aws_route" "private2" {
  route_table_id = aws_route_table.private2.id
  nat_gateway_id = aws_nat_gateway.howto_grpc_2.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private2" {
  route_table_id = aws_route_table.private2.id
  subnet_id = aws_subnet.private2.id
}

resource "aws_ecs_cluster" "howto_grpc" {
  name = var.project_name
}

resource "aws_security_group" "bastion" {
  name = "bastion"
  vpc_id = aws_vpc.howto_grpc.id
}

resource "aws_security_group_rule" "ingress_bastion" {
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "bastion" {
  ami = data.aws_ssm_parameter.awsec2_ami.value
  instance_type = "t2.micro"
  key_name = var.key_pair
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id = aws_subnet.public1.id
  tags = {
    Name = "bastion"
  }
}

resource "aws_ecr_repository" "client" {
  name = "${var.project_name}/${var.client_name}"
}

resource "aws_ecr_repository" "server" {
  name = "${var.project_name}/${var.server_name}"
}