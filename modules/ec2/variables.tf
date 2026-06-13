variable "environment" {
  type        = string
  description = "Entorno actual (ej: dev)"
}

variable "instance_type" {
  type        = string
  description = "Tamaño de la máquina EC2"
  default     = "t2.micro" # Cubierto por la capa gratuita de AWS
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC donde residirá el Security Group"
}

variable "subnet_id" {
  type        = string
  description = "ID de la subred pública donde nacerá la EC2"
}
