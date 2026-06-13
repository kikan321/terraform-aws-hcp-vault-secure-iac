output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "IP pública del servidor web desplegado"
}
