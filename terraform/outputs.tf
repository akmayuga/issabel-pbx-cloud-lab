output "public_ip" {
  description = "Public IP address assigned to the Issabel lab VM."
  value       = oci_core_instance.issabel.public_ip
}

output "ssh_command" {
  description = "SSH command for the default OCI Linux user."
  value       = "ssh opc@${oci_core_instance.issabel.public_ip}"
}

output "trusted_operator_cidr" {
  description = "CIDR Terraform used for admin access rules."
  value       = local.operator_cidr
}

output "sip_allowed_cidr" {
  description = "CIDR Terraform used for SIP/RTP access rules."
  value       = local.sip_cidr
}
