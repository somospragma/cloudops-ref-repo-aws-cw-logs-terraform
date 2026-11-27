# Configuración de providers para el ejemplo
provider "aws" {
  alias  = "principal"
  region = var.region

  dynamic "assume_role" {
    for_each = var.deploy_role_arn != "" ? [1] : []
    content {
      role_arn = var.deploy_role_arn
    }
  }

  default_tags {
    tags = var.common_tags
  }
}

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.20.0"
    }
  }
}
