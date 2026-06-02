# Security Hardening Guide

This lab is intentionally internet-capable so softphones can register from outside the cloud. That makes SIP brute force, web login attacks, and exposed monitoring the main risks.

## Baseline Controls

Use all of these before registering clients:

- Restrict SSH to `operator_public_ip_cidr`.
- Restrict SIP/RTP to `sip_allowed_cidr` or a WireGuard subnet.
- Restrict Grafana and Prometheus to your admin IP.
- Use 32+ character SIP passwords.
- Keep `terraform.tfvars`, API keys, and SIP passwords out of Git.
- Enable Fail2Ban and firewalld.
- Use HTTPS for the Issabel web GUI when a domain is available.
- Use WireGuard for remote SIP access when possible.

## Firewall

Cloud security lists block traffic before it reaches the VM. Firewalld blocks traffic on the VM. Both are used because cloud rules protect the instance edge, while host rules continue to work if the VM is moved or copied.

Required ports:

- `22/tcp`: SSH administration.
- `80/tcp`: HTTP and Let's Encrypt validation.
- `443/tcp`: HTTPS web GUI.
- `5060/udp` and `5060/tcp`: SIP registration and signaling.
- `10000-20000/udp`: RTP media.
- `51820/udp`: WireGuard.
- `3000/tcp`: Grafana.
- `9090/tcp`: Prometheus.

Avoid `0.0.0.0/0` for SIP except during short tests. If your softphone is on a changing home IP, prefer WireGuard.

## Fail2Ban

The playbook installs:

- `sshd` jail for SSH login attempts.
- `asterisk` jail for failed SIP registrations and common Asterisk security events.

Useful commands:

```bash
fail2ban-client status
fail2ban-client status asterisk
fail2ban-client unban <IP_ADDRESS>
```

## Strong Credentials

Generate passwords:

```bash
openssl rand -base64 32
```

Put them into `ansible/group_vars/issabel.yml`:

```yaml
extension_1001_password: "generated-value"
extension_1002_password: "generated-value"
```

Use separate voicemail PINs. Do not reuse SIP passwords as voicemail PINs.

## Disable Unnecessary Services

The install playbook tries to disable services that are unnecessary for this lab:

- `avahi-daemon`
- `bluetooth`
- `cups`
- `rpcbind`

Check listening ports:

```bash
ss -tulpn
```

## HTTPS

After DNS points to your VM, run:

```bash
/usr/local/sbin/letsencrypt.sh pbx.example.com admin@example.com
```

Temporarily allow `80/tcp` from the public internet if HTTP validation fails, then restrict it again.

## WireGuard

WireGuard reduces SIP exposure by making extensions register over a private network.

```bash
/usr/local/sbin/wireguard_setup.sh laptop pbx.example.com
```

Then set `sip_allowed_cidr` to the WireGuard subnet or your VPN client IP path instead of the whole internet.

## Monitoring Security

Grafana and Prometheus should never be globally exposed. Restrict ports `3000` and `9090` to your admin IP or access them through WireGuard/SSH tunneling:

```bash
ssh -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 opc@<PUBLIC_IP>
```

Then browse to `http://127.0.0.1:3000`.

## Log Review

Useful commands:

```bash
journalctl -u asterisk -n 100 --no-pager
journalctl -u fail2ban -n 100 --no-pager
tail -f /var/log/asterisk/messages
asterisk -rx "pjsip show contacts"
```
