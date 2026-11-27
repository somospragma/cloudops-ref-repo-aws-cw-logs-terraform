# Ejemplo de Uso del Módulo

Crea dos log groups (uno para WAF con prefijo `aws-waf-logs-` y uno de aplicación) y una política de recursos que permite a `delivery.logs.amazonaws.com` escribir en el de WAF, limitada a la cuenta actual.

```bash
cd sample
terraform init
terraform plan
```

Flujo (PC-IAC-026): `terraform.tfvars` -> `variables.tf` -> `locals.tf` -> `main.tf` -> módulo. La cuenta de origen de la política se inyecta en `locals.tf` desde `data.tf`.
