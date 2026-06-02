# Issabel PBX Free Cloud Lab

Complete Infrastructure as Code lab for learning Issabel PBX, Asterisk, SIP/PJSIP, IVR, voicemail, monitoring, backups, and cloud hardening.

## What You Get

- Terraform for an Oracle Cloud Infrastructure VM, VCN, subnet, public IP, route table, and firewall rules.
- Ansible playbooks for Issabel 5 preparation, Asterisk lab configuration, Fail2Ban, timers, health checks, backups, and monitoring helpers.
- PJSIP extensions `1001` and `1002` with strong password placeholders, voicemail, transfer support, call recording, CDR, ring group `600`, IVR `700`, and time condition `800`.
- Dockerized Prometheus, Grafana, Node Exporter, and Asterisk textfile metrics.
- Documentation for deployment, security, troubleshooting, SIP clients, call tests, cost comparison, and architecture.

## Repository Structure

```text
repository/
├── terraform/
├── ansible/
├── scripts/
├── docs/
├── monitoring/
├── backups/
└── README.md
```

## Best Free Provider

Use Oracle Cloud Free Tier first. Issabel 5 public media is x86_64, so the OCI Always Free Ampere A1 ARM shape is not the right target for this lab unless Issabel publishes ARM packages. The default Terraform path uses an x86_64 VM shape, with swap to make a tiny Always Free AMD micro shape usable for a lab. A 2 GB or larger x86_64 VM is much smoother if you have free trial credits.

## Publish a Free Demo

If you mainly need a public project demo for your portfolio, publish this repository with GitHub Pages. This is free and does not need a cloud VM. It publishes the project overview, architecture, deployment guide, security guide, and testing docs at a public URL.

Read [Free Publish Strategy](docs/free_publish_strategy.md).

## Quick Start

1. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`.
2. Fill in your OCI OCIDs, API key path, region, SSH key, and x86_64 image OCID.
3. Create infrastructure:

```bash
cd terraform
terraform init
terraform fmt
terraform validate
terraform apply
```

4. Put the Terraform `public_ip` output into `ansible/inventory.ini`.
5. Install Ansible dependencies and stage/install Issabel:

```bash
cd ..
ansible-galaxy collection install -r ansible/requirements.yml
ansible-playbook ansible/install_issabel.yml
```

6. SSH to the VM and run `/root/issabel5-netinstall.sh`, or set `run_issabel_netinstall: true` after reviewing installer behavior.
7. Edit `ansible/group_vars/issabel.yml` with real passwords, trusted CIDRs, public IP/domain, and email domain.
8. Configure lab extensions and PBX features:

```bash
ansible-playbook ansible/configure_pbx.yml
```

9. Start monitoring on the VM:

```bash
cd monitoring
GRAFANA_ADMIN_PASSWORD='replace-this' docker compose up -d
```

## Important Lab Notes

- Keep SIP/RTP restricted to your public IP or WireGuard subnet whenever possible.
- Do not commit `terraform.tfvars`, real SIP passwords, API tokens, private keys, or backups.
- This is a learning lab, not a production PBX design.
- Read [Deployment Guide](docs/deployment.md), [Security Guide](docs/security.md), and [Troubleshooting](docs/troubleshooting.md) before exposing SIP to the internet.
