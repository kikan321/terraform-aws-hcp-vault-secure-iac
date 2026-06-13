# Buscar la última AMI oficial de Ubuntu de forma dinámica
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID oficial de Canonical (creadores de Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Crear el Grupo de Seguridad en la VPC provista
resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg"
  description = "Permitir trafico HTTP de entrada"
  vpc_id      = var.vpc_id # Se inyectará desde el output de la VPC

  ingress {
    description = "HTTP de cualquier lado"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permitir todo hacia afuera"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-sg"
  }
}

# Crear la Instancia EC2
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id # Se inyectará desde el output de la VPC
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Instalar Nginx automáticamente al arrancar la máquina
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Desplegado exitosamente con Terraform y Vault</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.environment}-web-server"
  }
}
