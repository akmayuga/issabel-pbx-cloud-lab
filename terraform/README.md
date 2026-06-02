# Terraform

This directory provisions Oracle Cloud Infrastructure resources for the Issabel lab.

## Resources Created

- VCN: private cloud network for the lab.
- Internet gateway: public internet path for the VM.
- Route table: sends outbound internet traffic to the gateway.
- Security list: restricts SSH, web, SIP, RTP, WireGuard, Grafana, and Prometheus.
- Public subnet: places the VM on a reachable subnet.
- Compute instance: x86_64 VM for Issabel.
- Cloud-init swap setup: helps small free-tier VMs survive package installation.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform validate
terraform apply
```

## Image Selection

Use an x86_64 Oracle Linux 8, Rocky Linux 8, or AlmaLinux 8 image OCID in your OCI region. Issabel 5 public media is currently x86_64.

## Access Restrictions

Leave these empty to auto-detect your current public IP:

```hcl
operator_public_ip_cidr = ""
sip_allowed_cidr        = ""
web_allowed_cidr        = ""
```

For better repeatability, set explicit CIDRs:

```hcl
operator_public_ip_cidr = "203.0.113.10/32"
sip_allowed_cidr        = "203.0.113.10/32"
web_allowed_cidr        = "203.0.113.10/32"
```

## Destroy

```bash
terraform destroy
```

Download any needed backups before destroying the VM.
