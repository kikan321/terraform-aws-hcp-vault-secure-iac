# ==========================================
# 1. LLAMADA AL MÓDULO DE INFRAESTRUCTURA
# ==========================================

# Instanciamos el módulo de la VPC pasándole los parámetros específicos de DEV
module "vpc_development" {
  source = "../../modules/vpc"

  environment        = "dev"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
}

# =================================================================
# 2. MÓDULO DE CÓMPUTO (EC2) - CONECTADO DINÁMICAMENTE A LA VPC
# =================================================================
module "ec2_development" {
  source = "../../modules/ec2"

  environment   = "dev"
  instance_type = "t2.micro"

  # Aquí ocurre la magia: encadenamos las salidas del módulo VPC
  vpc_id    = module.vpc_development.vpc_id
  subnet_id = module.vpc_development.public_subnet_id
}

# ==========================================
# 3. OUTPUTS DEL ENTORNO
# ==========================================

# Exponemos el ID de la VPC creada en la terminal al finalizar el despliegue
output "dev_vpc_id" {
  value       = module.vpc_development.vpc_id
  description = "ID de la VPC de desarrollo creada mediante credenciales dinámicas"
}

output "web_server_public_ip" {
  value       = module.ec2_development.public_ip
  description = "IP pública para acceder al servidor web Nginx"
}
