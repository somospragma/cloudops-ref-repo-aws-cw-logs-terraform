# Invocación del módulo
module "cw_logs" {
  source = "../"

  providers = {
    aws.project = aws.principal
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  log_group_config       = var.log_group_config
  resource_policy_config = local.resource_policy_config_transformed
}
