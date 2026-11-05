output "instance_id" {
  description = "ID of the provisioned EC2 instance"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "Public IPv4 address of the deployed server"
  value       = aws_instance.app_server.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "application_url" {
  description = "Web URL to access the React frontend"
  value       = "http://${aws_instance.app_server.public_ip}"
}

output "api_url" {
  description = "API URL to access Django Backend"
  value       = "http://${aws_instance.app_server.public_ip}:8000/api/hello/"
}

