terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
resource "aws_ecs_cluster" "ecs-test" {
  name = "ecs-test"
}

resource "aws_ecs_cluster_capacity_providers" "cluster-capacity" {
  cluster_name       = aws_ecs_cluster.ecs-test.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "test-task" {
    execution_role_arn = "arn:aws:iam::699475927716:role/ecsTaskExecutionRole"
  family                   = "test-carvilla"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "carvilla",
    "image": "699475927716.dkr.ecr.ap-south-1.amazonaws.com/pawan-carvilla",
    "cpu": 0,
    "memory": 512,
    "essential": true,
    "portMappings": [
                {
                    "name": "carvilla-80-tcp",
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp",
                    "appProtocol": "http"
                },
                {
                    "name": "carvilla-8080-tcp",
                    "containerPort": 8080,
                    "hostPort": 8080,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ]
  }
]
TASK_DEFINITION
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "test-service" {
  name            = "test-service"
  cluster         = aws_ecs_cluster.ecs-test.id
  task_definition = aws_ecs_task_definition.test-task.id
  desired_count   = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets = ["subnet-00c8edbae49d06681"]
    security_groups = ["sg-0455b446125695436"]
    assign_public_ip = true
  }
}
