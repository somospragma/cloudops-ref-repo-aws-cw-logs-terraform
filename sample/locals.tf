# Transformaciones del ejemplo (PC-IAC-026): tfvars -> variables -> locals -> main -> module
locals {
  # Si no se indicaron cuentas de origen, se restringe a la cuenta actual (mínimo privilegio).
  resource_policy_config_transformed = {
    for key, pol in var.resource_policy_config : key => merge(pol, {
      source_account_ids = length(pol.source_account_ids) > 0 ? pol.source_account_ids : [data.aws_caller_identity.current.account_id]
    })
  }
}
