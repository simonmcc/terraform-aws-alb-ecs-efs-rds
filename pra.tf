# private registry access

# secrets need a random string appended to the name as they are
# queued for deletion - blocking stack destroy & create cycles
resource "random_string" "github_pat" {
  length  = 8
  special = false
}

resource "aws_secretsmanager_secret" "github_pat" {
  name = "github_pat-${random_string.github_pat.result}"
}

resource "aws_secretsmanager_secret_version" "github_pat" {
  secret_id     = aws_secretsmanager_secret.github_pat.id
  secret_string = jsonencode(var.private_registry_access_token)
}
