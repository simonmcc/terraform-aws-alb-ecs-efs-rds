resource "random_password" "database_password" {
  special = false
  length  = 24
}
# secrets need a random string appended to the name as they are
# queued for deletion - blocking stack destroy & create cycles
resource "random_string" "database_password_tag" {
  length  = 8
  special = false
}

resource "aws_secretsmanager_secret" "database_password" {
  name = "database_password-${random_string.database_password_tag.result}"
}

resource "aws_secretsmanager_secret_version" "database_password" {
  secret_id     = aws_secretsmanager_secret.database_password.id
  secret_string = random_password.database_password.result
}

resource "aws_security_group" "default" {
  vpc_id      = aws_vpc.main.id
  name        = format("%s-sg", var.name)
  description = format("Security Group for %s", var.name)

  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
    # cidr_blocks = [aws_vpc.main.cidr_block]
    cidr_blocks = aws_subnet.private.*.cidr_block
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# TODO: Move the database(s) to a subnet of their own
resource "aws_db_subnet_group" "default" {
  name        = var.name
  description = var.name
  subnet_ids  = aws_subnet.private.*.id
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = var.name
  vpc_security_group_ids  = [aws_security_group.default.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  engine_mode             = "serverless"
  enable_http_endpoint    = true
  master_username         = var.database_username
  master_password         = random_password.database_password.result
  backup_retention_period = 7
  skip_final_snapshot     = true

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 2
    seconds_until_auto_pause = 300
  }

  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
}