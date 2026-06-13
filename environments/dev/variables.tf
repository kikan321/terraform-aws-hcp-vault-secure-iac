variable "aws_region" {
  type        = string
  description = "Región de AWS donde se desplegará la infraestructura"
  default     = "us-east-1"
}

variable "vault_role_id" {
  type        = string
  description = "Role ID de AppRole para autenticarse en Vault"
  sensitive   = true # Evita que se muestre en los logs de la terminal
}

variable "vault_secret_id" {
  type        = string
  description = "Secret ID de AppRole para autenticarse en Vault"
  sensitive   = true # Evita que se muestre en los logs de la terminal
}
