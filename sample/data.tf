# Data sources del ejemplo
data "aws_caller_identity" "current" {
  provider = aws.principal
}
