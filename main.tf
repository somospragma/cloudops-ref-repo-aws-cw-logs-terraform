# Recursos principales del módulo

resource "aws_cloudwatch_log_group" "this" {
  provider = aws.project
  for_each = var.log_group_config

  name                        = local.log_group_names[each.key]
  retention_in_days           = each.value.retention_in_days
  kms_key_id                  = each.value.kms_key_id
  log_group_class             = each.value.log_group_class
  deletion_protection_enabled = each.value.deletion_protection_enabled
  skip_destroy                = each.value.skip_destroy

  tags = merge(
    { Name = local.log_group_names[each.key] },
    each.value.additional_tags
  )
}

# Política de recursos (ámbito cuenta y región). Máximo 10 por región.
resource "aws_cloudwatch_log_resource_policy" "this" {
  provider = aws.project
  for_each = var.resource_policy_config

  policy_name     = each.value.policy_name
  policy_document = local.resource_policy_documents[each.key]
}
