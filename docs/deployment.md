# Deployment Guide

This guide deploys the lab from scratch using Terraform, Ansible, and shell scripts stored in this repository.

## 0. If You Only Need a Free Online Demo

Use GitHub Pages first. It publishes the project documentation and demo homepage for free, without a VPS, payment method, or local device.

Read:

```text
docs/free_publish_strategy.md
```

Important: GitHub Pages cannot run Issabel or Asterisk. It only publishes the project/demo website. A live PBX still needs a VM provider.

## 1. Design Choice

The lab uses one public VM because Issabel is a full PBX appliance stack, not a stateless web app. It needs persistent storage, privileged services, SIP/RTP UDP networking, Asterisk, a web GUI, logs, recordings, and backups.

Oracle Cloud Infrastructure is the default target because it has real VM networking and Always Free resources. Issabel 5 public download media is x86_64, so use an x86_64 OCI image/shape. OCI Ampere A1 ARM is generous, but it is not a direct fit for the current public Issabel 5 media.

## 2. Local Prerequisites

Install these on your workstation:

- Terraform 1.5 or newer: provisions cloud infrastructure.
- Ansible 2.14 or newer: configures the VM repeatably.
- OCI account and API key: lets Terraform create resources.
- SSH key pair: lets Ansible and you log in to the VM.
- Git: stores all lab code and docs in one repository.

## 3. OCI Preparation

Create or identify these values in Oracle Cloud:

- Tenancy OCID
- User OCID
- API key fingerprint
- API private key path
- Compartment OCID
- Region
- x86_64 image OCID for Oracle Linux 8, Rocky Linux 8, or AlmaLinux 8

Why each value is needed:

- `tenancy_ocid`, `user_ocid`, `fingerprint`, `private_key_path`, and `region` authenticate Terraform to OCI.
- `compartment_ocid` selects where resources are created.
- `image_id` selects the VM operating system.
- `ssh_public_key_path` injects your SSH public key into the VM.
- `operator_public_ip_cidr` restricts SSH, Grafana, Prometheus, and WireGuard to your IP.
- `sip_allowed_cidr` restricts SIP and RTP to your softphone IP or VPN subnet.

## 4. Terraform

Copy the example variable file:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` and fill the OCI values. Then run:

```bash
cd terraform
terraform init
terraform fmt
terraform validate
terraform apply
```

Command explanations:

- `terraform init` downloads providers and initializes the working directory.
- `terraform fmt` formats HCL files so Terraform can read them consistently.
- `terraform validate` checks syntax and provider schema usage.
- `terraform apply` creates the VCN, subnet, route table, security list, and VM.

Record the `public_ip` output.

## 5. Ansible Inventory

Edit `ansible/inventory.ini`:

```ini
[issabel]
issabel_host ansible_host=<PUBLIC_IP> ansible_user=opc ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

The `opc` user is the normal Oracle Linux cloud image user. Use `rocky` or another user if your image requires it.

Install Ansible collections:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

## 6. Install Issabel

Run the install/hardening playbook:

```bash
ansible-playbook ansible/install_issabel.yml
```

This playbook:

- Installs host tools needed for troubleshooting and operations.
- Enables `chronyd`, `firewalld`, and `fail2ban`.
- Stages the official Issabel 5 netinstall script at `/root/issabel5-netinstall.sh`.
- Installs backup and health check scripts.
- Creates systemd timers for daily backups and Asterisk metrics.
- Disables nonessential services that are commonly present on generic images.

By default, the playbook does not automatically execute the Issabel installer because upstream installer prompts can change. SSH to the VM and run:

```bash
sudo /root/issabel5-netinstall.sh
```

If you have reviewed the installer behavior and want Ansible to run it, set this in `ansible/group_vars/issabel.yml`:

```yaml
run_issabel_netinstall: true
```

Then rerun:

```bash
ansible-playbook ansible/install_issabel.yml
```

## 7. Configure PBX Features

Edit `ansible/group_vars/issabel.yml` before configuring Asterisk:

- Replace `CHANGE_ME` values.
- Set `trusted_admin_cidr` and `trusted_sip_cidr`.
- Set `asterisk_public_ip` or `asterisk_external_host`.
- Set `voicemail_email_domain`.

Generate strong SIP passwords locally:

```bash
openssl rand -base64 32
```

Apply PBX configuration:

```bash
ansible-playbook ansible/configure_pbx.yml
```

This configures:

- PJSIP extensions `1001` and `1002`
- Voicemail boxes
- Internal calls
- Transfer support with `Tt` Dial options
- IVR `700`
- Ring group `600`
- Time condition demo `800`
- Call recording with `MixMonitor`
- CDR CSV logging

## 8. Monitoring

On the VM, install Docker once:

```bash
/usr/local/sbin/install_docker.sh
```

Then clone or copy this repository and run:

```bash
cd monitoring
GRAFANA_ADMIN_PASSWORD='replace-this' docker compose up -d
```

Command explanations:

- `docker compose up -d` starts Prometheus, Grafana, and Node Exporter in the background.
- `GRAFANA_ADMIN_PASSWORD` avoids the insecure default password.
- Node Exporter exposes CPU, memory, disk, and textfile metrics.
- The Asterisk metrics timer writes `asterisk_service_up` and `asterisk_pjsip_registered_contacts`.

Access:

- Grafana: `http://<PUBLIC_IP>:3000`
- Prometheus: `http://<PUBLIC_IP>:9090`

Keep these ports restricted in Terraform and firewalld.

## 9. Optional Features

Dynamic DNS:

```bash
export CF_API_TOKEN='...'
export CF_ZONE_ID='...'
export CF_RECORD_ID='...'
export CF_RECORD_NAME='pbx.example.com'
/usr/local/sbin/dynamic_dns.sh
```

HTTPS:

```bash
/usr/local/sbin/letsencrypt.sh pbx.example.com admin@example.com
```

WireGuard:

```bash
/usr/local/sbin/wireguard_setup.sh laptop pbx.example.com
```

Backup:

```bash
/usr/local/sbin/backup.sh
```

Restore:

```bash
/usr/local/sbin/restore.sh /var/backups/issabel/issabel-backup-YYYYMMDD-HHMMSS.tar.gz
```

Health check:

```bash
/usr/local/sbin/healthcheck.sh
```

## 10. Cleanup

Destroy cloud resources:

```bash
cd terraform
terraform destroy
```

This removes the VM and networking created by Terraform. Download needed backups before destroying the instance.
