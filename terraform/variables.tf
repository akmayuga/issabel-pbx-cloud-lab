variable "project_name" {
  description = "Prefix used for OCI resource names."
  type        = string
  default     = "issabel-lab"
}

variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCI user OCID for Terraform API access."
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint for the OCI API signing key."
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the OCI API private key."
  type        = string
}

variable "region" {
  description = "OCI region, for example us-ashburn-1."
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "OCI compartment OCID where the lab will be created."
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Local SSH public key path for VM access."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "image_id" {
  description = "OCI image OCID. Use an x86_64 Oracle Linux 8, Rocky Linux 8, or AlmaLinux 8 image for Issabel 5 netinstall."
  type        = string
}

variable "instance_shape" {
  description = "OCI instance shape. VM.Standard.E2.1.Micro is Always Free x86_64 but tight; a trial-credit 2 GB+ x86_64 shape is smoother."
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "a1_ocpus" {
  description = "OCPUs for Ampere A1 Flex. Issabel 5 public ISO/netinstall is x86_64, so this is normally unused."
  type        = number
  default     = 1
}

variable "a1_memory_gbs" {
  description = "Memory for Ampere A1 Flex. Issabel 5 public ISO/netinstall is x86_64, so this is normally unused."
  type        = number
  default     = 6
}

variable "availability_domain_index" {
  description = "Zero-based availability domain index."
  type        = number
  default     = 0
}

variable "vcn_cidr" {
  description = "VCN CIDR block."
  type        = string
  default     = "10.60.0.0/16"
}

variable "subnet_cidr" {
  description = "Public subnet CIDR block."
  type        = string
  default     = "10.60.10.0/24"
}

variable "operator_public_ip_cidr" {
  description = "Trusted admin source CIDR for SSH, monitoring, and WireGuard. Empty auto-detects your current public IP."
  type        = string
  default     = ""
}

variable "sip_allowed_cidr" {
  description = "Trusted SIP/RTP client CIDR. Empty uses operator_public_ip_cidr/current IP. Use 0.0.0.0/0 only for temporary testing."
  type        = string
  default     = ""
}

variable "web_allowed_cidr" {
  description = "Trusted HTTP/HTTPS source CIDR. Empty uses operator_public_ip_cidr/current IP. Use 0.0.0.0/0 only when issuing Let's Encrypt."
  type        = string
  default     = ""
}

variable "rtp_start_port" {
  description = "Asterisk RTP start port."
  type        = number
  default     = 10000
}

variable "rtp_end_port" {
  description = "Asterisk RTP end port."
  type        = number
  default     = 20000
}

variable "wireguard_port" {
  description = "WireGuard UDP listen port."
  type        = number
  default     = 51820
}

variable "swap_size_gb" {
  description = "Swap file size created by cloud-init. Useful on 1 GB free-tier VMs."
  type        = number
  default     = 2
}
