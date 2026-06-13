output "vpc_id" {
  value       = aws_vpc.main.id
  description = "El ID de la VPC creada"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "El ID de la subred pública"
}
