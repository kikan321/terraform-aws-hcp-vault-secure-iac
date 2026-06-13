terraform {
  required_version = ">= 1.5.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Reemplaza la autenticación de token por AppRole
provider "vault" {
  # IMPORTANTE: HCP Vault requiere especificar el namespace admin para AppRole
  namespace = "admin"

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.vault_role_id     
      secret_id = var.vault_secret_id
    }
  }
}

# Solicitamos credenciales dinámicas de AWS a Vault
data "vault_aws_access_credentials" "aws_creds" {
  backend = "aws"                 # Nombre del motor de secretos en Vault
  role    = "terraform-dev-role"  # Rol que crearemos dentro de Vault
}

# Configuramos el proveedor de AWS con los datos temporales que nos dio Vault
provider "aws" {
  region     = var.aws_region
  access_key = data.vault_aws_access_credentials.aws_creds.access_key
  secret_key = data.vault_aws_access_credentials.aws_creds.secret_key
  token      = data.vault_aws_access_credentials.aws_creds.security_token
}
