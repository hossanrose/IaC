output "region" {
  description = "AWS region"
  value       = var.region
}

output "yo_msk_name" {
  description = "Yo broker name"
  value       = aws_msk_cluster.msk.bootstrap_brokers
}
