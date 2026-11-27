# Outputs del módulo

output "log_group_arns" {
  description = "ARN de cada log group (sin el sufijo :*), por clave de log_group_config"
  value       = { for key, lg in aws_cloudwatch_log_group.this : key => lg.arn }
}

output "log_group_names" {
  description = "Nombre de cada log group, por clave de log_group_config"
  value       = { for key, lg in aws_cloudwatch_log_group.this : key => lg.name }
}

output "all_log_group_arns" {
  description = "Lista de ARN de todos los log groups creados"
  value       = values(aws_cloudwatch_log_group.this)[*].arn
}

output "resource_policy_names" {
  description = "Nombre de cada política de recursos creada, por clave de resource_policy_config"
  value       = { for key, pol in aws_cloudwatch_log_resource_policy.this : key => pol.policy_name }
}
