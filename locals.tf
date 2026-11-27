# Valores locales y transformaciones
locals {
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Nombre final del log group: override exacto, o <prefijo><cliente-proyecto-entorno>-lg-<clave>
  log_group_names = {
    for key, cfg in var.log_group_config : key => (
      cfg.name_override != "" ? cfg.name_override : "${cfg.name_prefix}${local.governance_prefix}-lg-${key}"
    )
  }

  # Política de recursos por clave. La condición solo se agrega si se indicaron cuentas o ARN de origen.
  resource_policy_documents = {
    for key, pol in var.resource_policy_config : key => jsonencode({
      Version = "2012-10-17"
      Statement = [
        merge(
          {
            Sid       = "AllowServiceDelivery"
            Effect    = "Allow"
            Principal = { Service = pol.service_principals }
            Action    = pol.actions
            Resource  = [for lk in pol.log_group_keys : "${aws_cloudwatch_log_group.this[lk].arn}:*"]
          },
          length(pol.source_account_ids) + length(pol.source_arn_pattern) > 0 ? {
            Condition = merge(
              length(pol.source_account_ids) > 0 ? { StringEquals = { "aws:SourceAccount" = pol.source_account_ids } } : {},
              length(pol.source_arn_pattern) > 0 ? { ArnLike = { "aws:SourceArn" = pol.source_arn_pattern } } : {}
            )
          } : {}
        )
      ]
    })
  }
}
