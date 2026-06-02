variable "project_name" {
  description = "Prefix used for AWS resource names."
  type        = string
  default     = "issabel-pbx-lab"
}

variable "aws_region" {
  description = "AWS region. ap-southeast-2 is Sydney."
  type        = string
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "Free-tier eligible type depends on your account and region. Check the EC2 picker."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name."
  type        = string
}

variable "ami_id" {
  description = "Optional explicit x86_64 AMI ID. Leave empty to use ami_name_pattern search."
  type        = string
  default     = ""
}

variable "ami_owners" {
  description = "AMI owner IDs. Use official or trusted owner IDs for your selected OS."
  type        = list(string)
  default     = ["679593333241"]
}

variable "ami_name_pattern" {
  description = "AMI name search pattern. Default targets Rocky Linux 8 x86_64 Marketplace images when available."
  type        = string
  default     = "Rocky-8-EC2-Base-8.*x86_64*"
}

variable "operator_public_ip_cidr" {
  description = "Trusted admin source CIDR. Empty auto-detects your current public IP."
  type        = string
  default     = ""
}

variable "sip_allowed_cidr" {
  description = "Trusted SIP/RTP client CIDR. Empty uses operator_public_ip_cidr/current IP."
  type        = string
  default     = ""
}

variable "web_allowed_cidr" {
  description = "Trusted HTTP/HTTPS source CIDR. Empty uses operator_public_ip_cidr/current IP."
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

variable "root_volume_size_gb" {
  description = "Root EBS volume size."
  type        = number
  default     = 30
}

variable "swap_size_gb" {
  description = "Swap file size created by cloud-init."
  type        = number
  default     = 2
}
