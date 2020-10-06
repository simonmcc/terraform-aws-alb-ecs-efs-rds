#
# Fargate 1.4.0 has 2 roles:
# * Task Execution Role (image pull & related secrets, logging)
# * Task Role (Firelens, EFS Storage Traffic & Application Traffic)
#
# There is a managed policy (AmazonECSTaskExecutionRolePolicy) which grants ECR &
# logging access (see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html)

# ECS task execution role

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name}-TaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "logging" {
  name   = "${var.name}-log-permissions"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_policy" "ecs_secret_access" {
  name   = "${var.name}-ecs_secret_access"
  policy = data.aws_iam_policy_document.ecs_secret_access.json
}

data "aws_iam_policy_document" "ecs_secret_access" {
  version = "2012-10-17"
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      // We're using the default KMS Key, so we don't need to specify "kms:Decrypt"
    ]
    resources = [
      "${aws_secretsmanager_secret_version.github_pat.arn}",
      "${aws_secretsmanager_secret_version.database_password.arn}"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_secret_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secret_access.arn
}

resource "aws_iam_role_policy" "ecr_access" {
  role   = aws_iam_role.ecs_task_execution_role.name
  policy = data.aws_iam_policy_document.ecr_access.json
}

data "aws_iam_policy_document" "ecr_access" {
  version = "2012-10-17"
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }
}

#####
# IAM - Task role, basic. Append policies to this role for S3, DynamoDB etc.
#####
resource "aws_iam_role" "task" {
  name               = "${var.name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}

resource "aws_iam_role_policy" "log_agent" {
  name   = "${var.name}-log-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.logging.json
}

data "aws_iam_policy_document" "task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Task logging privileges
data "aws_iam_policy_document" "logging" {
  statement {
    effect = "Allow"

    resources = [
      aws_cloudwatch_log_group.log_group.arn
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}
