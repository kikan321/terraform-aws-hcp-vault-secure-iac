variable "environment" {
  type        = string
  description = "Nombre del entorno (ej: dev, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "Rango CIDR para la VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Rango CIDR para la subred pública"
  default     = "10.0.1.0/24"
}
