# Valores de variables para el ejemplo (sin secretos ni IDs)
region      = "us-east-1"
client      = "pragma"
project     = "sopp"
environment = "dev"

common_tags = {
  Client      = "pragma"
  Project     = "sopp"
  Environment = "dev"
  Owner       = "cloudops"
  CostCenter  = "9952"
}

log_group_config = {
  # WAF exige que el nombre empiece por "aws-waf-logs-"
  "waf-regional" = {
    name_prefix       = "aws-waf-logs-"
    retention_in_days = 90
  }
  "app" = {
    retention_in_days = 30
  }
}

resource_policy_config = {
  "waf" = {
    policy_name        = "pragma-sopp-dev-waf-logs"
    service_principals = ["delivery.logs.amazonaws.com"]
    log_group_keys     = ["waf-regional"]
  }
}
