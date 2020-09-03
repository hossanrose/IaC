# Output variable definitions

output "efs_id" {
  description = "ID of EFS filesystem"
  value       = aws_efs_file_system.efs.id
}
