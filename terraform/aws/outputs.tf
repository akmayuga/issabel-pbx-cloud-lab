output "public_ip" {
  description = "Public IP of the AWS Issabel lab instance."
  value       = aws_instance.pbx.public_ip
}

output "public_dns" {
  description = "Public DNS name of the AWS Issabel lab instance."
  value       = aws_instance.pbx.public_dns
}

output "ssh_rocky_command" {
  description = "SSH command for Rocky Linux AMIs."
  value       = "ssh -i ~/.ssh/${var.key_name}.pem rocky@${aws_instance.pbx.public_ip}"
}

output "trusted_operator_cidr" {
  description = "CIDR used for SSH/admin/monitoring access."
  value       = local.operator_cidr
}

output "sip_allowed_cidr" {
  description = "CIDR used for SIP/RTP access."
  value       = local.sip_cidr
}
