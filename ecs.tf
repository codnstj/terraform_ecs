data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-staging-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "template_file" "service" {
  template = file(var.tpl_path)
  vars = {
    region = "ap-northeast-2"
    aws_ecr_repository = aws_ecr_repository.repo.repository_url
    tag = "latest"
    conatainer_port = 80
    host_port = 80
    app_name = var.app_name
  }
}

resource "aws_ecs_task_definition" "service" {
  family = "staged"
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions = data.template_file.service.rendered
  tags = {
    "Environment" = "staging"
    Application = var.app_name
  }
}