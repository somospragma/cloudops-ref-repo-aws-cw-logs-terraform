# AWS CloudWatch Logs Terraform Module

Crea log groups de CloudWatch con retención obligatoria y, de forma opcional, políticas de recursos de CloudWatch Logs que permiten a un servicio (WAF, Route 53, etc.) escribir en ellos.

## Recursos

- `aws_cloudwatch_log_group`
- `aws_cloudwatch_log_resource_policy` (opcional, ámbito cuenta y región)

## Uso

```hcl
module "cw_logs" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-cw-logs-terraform.git?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "sopp"
  environment = "dev"

  log_group_config = {
    "waf-regional" = {
      name_prefix       = "aws-waf-logs-"   # WAF exige este prefijo
      retention_in_days = 90
    }
  }

  resource_policy_config = {
    "waf" = {
      policy_name        = "pragma-sopp-dev-waf-logs"
      service_principals = ["delivery.logs.amazonaws.com"]
      log_group_keys     = ["waf-regional"]
      source_account_ids = ["123456789012"]
    }
  }
}
```

Nombre del log group: `<name_prefix><client>-<project>-<environment>-lg-<clave>`, o `name_override` tal cual cuando el servicio impone el nombre.

## Inputs

| Nombre | Descripción | Tipo | Por defecto |
|---|---|---|---|
| `client` | Cliente (minúsculas y números, máx. 10) | `string` | requerido |
| `project` | Proyecto (minúsculas y números, máx. 15) | `string` | requerido |
| `environment` | `dev`, `qa`, `staging`, `pdn`, `prod` | `string` | requerido |
| `log_group_config` | Mapa de log groups (ver campos abajo) | `map(object)` | `{}` |
| `resource_policy_config` | Mapa de políticas de recursos | `map(object)` | `{}` |

Campos de `log_group_config`: `name_override`, `name_prefix`, `retention_in_days` (90), `kms_key_id` (null), `log_group_class` (`STANDARD`), `deletion_protection_enabled` (false), `skip_destroy` (false), `additional_tags`.

Campos de `resource_policy_config`: `policy_name`, `service_principals`, `log_group_keys`, `actions` (`CreateLogStream`, `PutLogEvents`), `source_account_ids`, `source_arn_pattern`.

## Outputs

| Nombre | Descripción |
|---|---|
| `log_group_arns` | ARN por clave (sin el sufijo `:*`) |
| `log_group_names` | Nombre por clave |
| `all_log_group_arns` | Lista de ARN |
| `resource_policy_names` | Nombre de las políticas de recursos creadas |

## Requisitos

| Nombre | Versión |
|---|---|
| terraform | >= 1.9.0 |
| aws (alias `aws.project`) | >= 6.20.0 |

## Cumplimiento (PC-IAC)

| Regla | Cómo se aplica |
|---|---|
| 001 | Estructura de archivos del módulo y de `sample/` |
| 002 | Variables tipadas con `description` y `validation`; colecciones como `map(object)` |
| 003 | Nombre construido en `locals.tf` con el prefijo de gobernanza |
| 004 | `tags = merge({ Name = ... }, additional_tags)`; `default_tags` en el Root |
| 005 / 006 | Alias consumidor `aws.project` y versiones en `versions.tf`; sin backend |
| 007 / 014 | Outputs granulares (ARN, nombre) con splat |
| 010 | `for_each` sobre mapas |
| 020 | Retención obligatoria (0 no permitido), KMS opcional validado y política de recursos con condición de cuenta |
| 023 | El módulo solo crea log groups y sus políticas de recursos |
| 026 | `sample/` con el flujo tfvars -> variables -> locals -> main |

## Decisiones de diseño

- **Retención obligatoria.** No se permite `0` (infinita), para cumplir `LOG-MIN-002` del framework de observabilidad.
- **Política de recursos.** Es opcional y de ámbito cuenta y región: AWS permite 10 por región. Se recomienda `source_account_ids` para limitar quién puede escribir.
- **KMS opcional.** Se valida el formato del ARN. Si la clave no concede permisos al servicio de logs, la creación falla.
- **Nombres.** `name_override` cubre los casos en que el servicio fija el nombre (por ejemplo `/aws/lambda/...`). No se combina con `name_prefix`.
- **Gobernanza.** El módulo recibe `client`, `project` y `environment` para construir el nombre, igual que los demás módulos de referencia de la organización (`iam`, `waf`).
