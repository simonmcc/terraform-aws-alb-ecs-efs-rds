# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

data "template_file" "app" {
  template = file("${path.module}/templates/ecs/app.json.tpl")

  vars = {
    APP_NAME              = var.name
    app_image             = var.app_image
    app_image_tag         = var.app_image_tag
    app_port              = var.app_port
    fargate_cpu           = var.fargate_cpu
    fargate_memory        = var.fargate_memory
    aws_region            = data.aws_region.current.name
    DATABASE_HOSTNAME     = aws_rds_cluster.default.endpoint
    DATABASE_USERNAME     = var.database_username
    DATABASE_PASSWORD_ARN = aws_secretsmanager_secret_version.database_password.arn
    EFS_VOLUME            = "${var.name}_filestore"
  }
}

resource "local_file" "debug_container_definition" {
  count    = 1
  content  = data.template_file.app.rendered
  filename = "${path.root}/container_definition.js"
}

resource "aws_ecs_task_definition" "app" {
  family             = "${var.name}-task"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn            = aws_iam_role.task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.app.rendered

  volume {
    name = "${var.name}_filestore"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.app_filestore.id
      root_directory = "/"
    }
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  // 2020-06-28, defaults to 1.3.0, EFS is supported from 1.4.0 upwards
  platform_version = "1.4.0"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = var.name
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end]
}
