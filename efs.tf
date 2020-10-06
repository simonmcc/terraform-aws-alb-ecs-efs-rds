resource "aws_efs_file_system" "app_filestore" {
  tags = {
    Name = "${var.name}-efs"
  }
}

# efs mount point fpr each private subnet
resource "aws_efs_mount_target" "mount" {
  count           = length(aws_subnet.private.*.id)
  file_system_id  = aws_efs_file_system.app_filestore.id
  subnet_id       = element(aws_subnet.private.*.id, count.index)
  security_groups = [aws_security_group.efs_access.id]
}

# Security Group to control access to the EFS mount targets
resource "aws_security_group" "efs_access" {
  name        = "efs-access"
  description = "EFS Access Control"
  vpc_id      = aws_vpc.main.id

  # Allow NFS access from the ECS Tasks
  ingress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}
