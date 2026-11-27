# Changelog

## [Unreleased]

## [1.0.0]
### Added
- Log groups de CloudWatch con retención obligatoria (por defecto 90 días), KMS opcional, clase de log y protección contra eliminación.
- Políticas de recursos de CloudWatch Logs (ámbito cuenta y región) opcionales, con condiciones `aws:SourceAccount` y `aws:SourceArn`.
