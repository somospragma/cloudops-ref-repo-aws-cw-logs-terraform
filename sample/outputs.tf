# Outputs del ejemplo
output "log_group_arns" {
  description = "ARN de los log groups creados"
  value       = module.cw_logs.log_group_arns
}

output "log_group_names" {
  description = "Nombres de los log groups creados"
  value       = module.cw_logs.log_group_names
}

output "resource_policy_names" {
  description = "Políticas de recursos creadas"
  value       = module.cw_logs.resource_policy_names
}
