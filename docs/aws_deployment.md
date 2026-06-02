# AWS EC2 Deployment Guide

Use this when you have AWS Free Tier or promotional credits. Your screenshot shows AWS region `Asia Pacific (Sydney)`, which is `ap-southeast-2`.

## Cost Warning

AWS free usage depends on your account eligibility, instance type, region, storage, public IP behavior, and data transfer. Before launching anything:

- Open `Billing and Cost Management`.
- Create a budget alert at a small amount, for example `1 USD`.
- Stop or terminate the instance when you are done testing.
- Avoid extra services such as NAT Gateway, Load Balancer, paid AMIs, snapshots, and large EBS volumes.

## Recommended Lab Shape

For a free-tier style test:

- Region: `Asia Pacific (Sydney) ap-southeast-2`
- Instance: choose an EC2 type marked `Free tier eligible`, usually `t3.micro` or `t2.micro` depending on region/account
- OS: Rocky Linux 8, AlmaLinux 8, or Oracle Linux 8, x86_64
- Disk: 30 GB gp3
- Public IPv4: enabled
- Swap: 2 GB

Issabel can be heavy on a micro instance. For a short demo, it can work, but expect slow installs.

## Option A: Launch with AWS Console

1. In AWS console, search for `EC2`.
2. Click `Launch instance`.
3. Name: `issabel-pbx-lab`.
4. Application and OS Image:
   - Pick Rocky Linux 8, AlmaLinux 8, or Oracle Linux 8 x86_64.
   - Avoid ARM images for this lab.
5. Instance type:
   - Pick a type marked `Free tier eligible`.
   - Prefer `t3.micro` if available.
6. Key pair:
   - Create a new key pair named `issabel-lab-key`.
   - Type: RSA or ED25519.
   - Format: `.pem`.
   - Download it and keep it safe.
7. Network settings:
   - Auto-assign public IP: enabled.
   - Create security group named `issabel-pbx-lab-sg`.
8. Add inbound rules:

| Type | Protocol | Port | Source |
|---|---|---:|---|
| SSH | TCP | 22 | Your IP |
| HTTP | TCP | 80 | Your IP |
| HTTPS | TCP | 443 | Your IP |
| Custom UDP | UDP | 5060 | Your IP |
| Custom TCP | TCP | 5060 | Your IP |
| Custom UDP | UDP | 10000-20000 | Your IP |
| Custom UDP | UDP | 51820 | Your IP |
| Custom TCP | TCP | 3000 | Your IP |
| Custom TCP | TCP | 9090 | Your IP |

For demos with a softphone from another network, update the SIP/RTP rules to that network's public IP.

9. Launch instance.
10. Wait until instance state is `running`.
11. Copy the public IPv4 address.

## Connect to the Server

Move your key to `~/.ssh` and lock permissions:

```bash
mkdir -p ~/.ssh
mv ~/Downloads/issabel-lab-key.pem ~/.ssh/
chmod 400 ~/.ssh/issabel-lab-key.pem
```

SSH user depends on OS:

```bash
ssh -i ~/.ssh/issabel-lab-key.pem rocky@<PUBLIC_IP>
```

or:

```bash
ssh -i ~/.ssh/issabel-lab-key.pem ec2-user@<PUBLIC_IP>
```

or:

```bash
ssh -i ~/.ssh/issabel-lab-key.pem almalinux@<PUBLIC_IP>
```

## Configure Ansible Inventory

Edit `ansible/inventory.ini`:

```ini
[issabel]
issabel_host ansible_host=<PUBLIC_IP> ansible_user=rocky ansible_ssh_private_key_file=~/.ssh/issabel-lab-key.pem
```

If your SSH user is `ec2-user` or `almalinux`, change `ansible_user`.

## Install and Configure Issabel

Install Ansible collection:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

Stage prerequisites and security:

```bash
ansible-playbook ansible/install_issabel.yml
```

SSH into the server and run the Issabel installer:

```bash
sudo /root/issabel5-netinstall.sh
```

After install finishes, edit:

```text
ansible/group_vars/issabel.yml
```

Set:

```yaml
asterisk_public_ip: "<PUBLIC_IP>"
trusted_admin_cidr: "<YOUR_PUBLIC_IP>/32"
trusted_sip_cidr: "<YOUR_PUBLIC_IP>/32"
extension_1001_password: "generate-a-long-password"
extension_1002_password: "generate-a-long-password"
```

Generate passwords:

```bash
openssl rand -base64 32
```

Apply PBX config:

```bash
ansible-playbook ansible/configure_pbx.yml
```

## Register SIP Extensions

Use Zoiper, Linphone, or MicroSIP.

Extension `1001`:

```text
SIP server/domain: <PUBLIC_IP>
Username: 1001
Auth username: 1001
Password: extension_1001_password
Port: 5060
Transport: UDP
```

Extension `1002`:

```text
SIP server/domain: <PUBLIC_IP>
Username: 1002
Auth username: 1002
Password: extension_1002_password
Port: 5060
Transport: UDP
```

Check registration:

```bash
sudo asterisk -rx "pjsip show contacts"
```

## Test Calls

Dial:

- `1001` to call extension 1001
- `1002` to call extension 1002
- `600` for ring group
- `700` for IVR
- `800` for time condition demo
- `*97` for voicemail

## Option B: Launch with Terraform

Configure AWS CLI first:

```bash
aws configure
```

Then:

```bash
cp terraform/aws/terraform.tfvars.example terraform/aws/terraform.tfvars
cd terraform/aws
terraform init
terraform validate
terraform apply
```

If Terraform cannot find an AMI, use the EC2 console to find a valid x86_64 Rocky/Alma/Oracle Linux 8 AMI ID in `ap-southeast-2`, then set:

```hcl
ami_id = "ami-xxxxxxxxxxxxxxxxx"
```

## Stop Costs

To pause billing for compute:

```bash
aws ec2 stop-instances --instance-ids <INSTANCE_ID>
```

To delete everything created by Terraform:

```bash
cd terraform/aws
terraform destroy
```

If launched manually, terminate the EC2 instance and delete old snapshots or unattached EBS volumes.

## Sources

- AWS EC2 Free Tier overview: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-free-tier-usage.html
- AWS EC2 key pairs: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
- AWS connect to Linux instance: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect.html
- AWS security group port ranges: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/changing-security-group.html
