resource "aws_efs_file_system" "efs" {
  creation_token   = var.token
  performance_mode = "generalPurpose"
  tags             = var.tags
}
resource "aws_efs_mount_target" "efs" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet
  security_groups = var.security_groups
}
