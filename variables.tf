# Variables de entrada del módulo

###########################################
########## Variables de gobernanza ########
###########################################

variable "client" {
  type        = string
  description = "Nombre del cliente (minúsculas y números, máximo 10 caracteres)"

  validation {
    condition     = can(regex("^[a-z0-9]{1,10}$", var.client))
    error_message = "client debe ser alfanumérico en minúsculas, de 1 a 10 caracteres."
  }
}

variable "project" {
  type        = string
  description = "Nombre del proyecto (minúsculas y números, máximo 15 caracteres)"

  validation {
    condition     = can(regex("^[a-z0-9]{1,15}$", var.project))
    error_message = "project debe ser alfanumérico en minúsculas, de 1 a 15 caracteres."
  }
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue (dev, qa, staging, pdn, prod)"

  validation {
    condition     = contains(["dev", "qa", "staging", "pdn", "prod"], var.environment)
    error_message = "environment debe ser uno de: dev, qa, staging, pdn, prod."
  }
}

###########################################
########## Log groups #####################
###########################################

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
  default     = {}
  description = <<EOF
    Mapa de log groups a crear. La clave identifica el log group dentro del módulo.

    - name_override: (opcional) nombre exacto del log group. Úsese cuando el servicio impone el nombre (ej. /aws/lambda/mi-funcion).
    - name_prefix: (opcional) texto que se antepone al nombre estándar. Para WAF debe ser "aws-waf-logs-".
    - retention_in_days: días de retención (por defecto 90). 0 (retención infinita) no está permitido.
    - kms_key_id: (opcional) ARN de la clave KMS para cifrar los logs. Si no se indica, se usa el cifrado por defecto de CloudWatch.
    - log_group_class: STANDARD, INFREQUENT_ACCESS o DELIVERY.
    - deletion_protection_enabled: (opcional) protege el log group contra eliminación.
    - skip_destroy: (opcional) si es true, al destruir solo se saca del estado y se conservan los logs.
    - additional_tags: (opcional) tags adicionales.
  EOF

  validation {
    condition = alltrue([
      for k, v in var.log_group_config :
      contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], v.retention_in_days)
    ])
    error_message = "retention_in_days debe ser un valor válido de CloudWatch Logs (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653). 0 no está permitido."
  }

  validation {
    condition = alltrue([
      for k, v in var.log_group_config :
      contains(["STANDARD", "INFREQUENT_ACCESS", "DELIVERY"], v.log_group_class)
    ])
    error_message = "log_group_class debe ser STANDARD, INFREQUENT_ACCESS o DELIVERY."
  }

  validation {
    condition = alltrue([
      for k, v in var.log_group_config :
      v.kms_key_id == null ? true : can(regex("^arn:aws[a-z-]*:kms:[a-z0-9-]+:[0-9]{12}:key/", v.kms_key_id))
    ])
    error_message = "kms_key_id debe ser el ARN de una clave KMS (arn:aws:kms:<region>:<cuenta>:key/<id>)."
  }

  validation {
    condition = alltrue([
      for k, v in var.log_group_config :
      !(v.name_override != "" && v.name_prefix != "")
    ])
    error_message = "Use name_override o name_prefix, no ambos."
  }
}

###########################################
########## Políticas de recursos ##########
###########################################

variable "resource_policy_config" {
  type = map(object({
    policy_name        = string
    service_principals = list(string)
    log_group_keys     = list(string)
    actions            = optional(list(string), ["logs:CreateLogStream", "logs:PutLogEvents"])
    source_account_ids = optional(list(string), [])
    source_arn_pattern = optional(list(string), [])
  }))
  default     = {}
  description = <<EOF
    Mapa de políticas de recursos de CloudWatch Logs (ámbito cuenta/región) que permiten a un servicio escribir en los log groups.
    Hay un máximo de 10 por región y cuenta: si ya existe una equivalente, no la duplique.

    - policy_name: nombre de la política (único en la cuenta y región).
    - service_principals: servicios que escriben (ej. ["delivery.logs.amazonaws.com"]).
    - log_group_keys: claves de log_group_config sobre las que aplica.
    - actions: acciones permitidas (por defecto CreateLogStream y PutLogEvents).
    - source_account_ids: (recomendado) cuentas de origen permitidas (condición aws:SourceAccount).
    - source_arn_pattern: (opcional) patrones de ARN de origen permitidos (condición aws:SourceArn).
  EOF

  validation {
    condition = alltrue(flatten([
      for k, p in var.resource_policy_config : [
        for lk in p.log_group_keys : contains(keys(var.log_group_config), lk)
      ]
    ]))
    error_message = "Cada valor de log_group_keys debe existir como clave en log_group_config."
  }

  validation {
    condition = alltrue([
      for k, p in var.resource_policy_config :
      length(p.service_principals) > 0 && length(p.log_group_keys) > 0
    ])
    error_message = "service_principals y log_group_keys no pueden estar vacíos."
  }
}
