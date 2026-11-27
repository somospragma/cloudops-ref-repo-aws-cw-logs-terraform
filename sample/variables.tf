# Variables del ejemplo
variable "region" {
  type        = string
  description = "Región AWS"
  default     = "us-east-1"
}

variable "client" {
  type        = string
  description = "Nombre del cliente"
}

variable "project" {
  type        = string
  description = "Nombre del proyecto"
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue"
}

variable "common_tags" {
  type        = map(string)
  description = "Tags comunes (default_tags del provider)"
}

variable "deploy_role_arn" {
  type        = string
  description = "Rol IAM para el despliegue (vacío = credenciales actuales)"
  default     = ""
}

variable "log_group_config" {
  type = map(object({
    name_override               = optional(string, "")
    name_prefix                 = optional(string, "")
    retention_in_days           = optional(number, 90)
    kms_key_id                  = optional(string, null)
    log_group_class             = optional(string, "STANDARD")
    deletion_protection_enabled = optional(bool, false)
    skip_destroy                = optional(bool, false)
    additional_tags             = optional(map(string), {})
  }))
  description = "Log groups a crear"
  default     = {}
}

variable "resource_policy_config" {
  type = map(object({
    policy_name        = string
    service_principals = list(string)
    log_group_keys     = list(string)
    actions            = optional(list(string), ["logs:CreateLogStream", "logs:PutLogEvents"])
    source_account_ids = optional(list(string), [])
    source_arn_pattern = optional(list(string), [])
  }))
  description = "Políticas de recursos de CloudWatch Logs"
  default     = {}
}
