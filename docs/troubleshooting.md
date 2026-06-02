# Troubleshooting Guide

## SSH Fails

Check the Terraform output and inventory:

```bash
terraform -chdir=terraform output public_ip
ssh -i ~/.ssh/id_ed25519 opc@<PUBLIC_IP>
```

If SSH times out, verify `operator_public_ip_cidr` and the OCI security list.

## Terraform Cannot Create the VM

Common causes:

- Wrong region for the image OCID.
- Shape capacity unavailable in the selected availability domain.
- Compartment OCID or policy permissions are incorrect.
- API key fingerprint or private key path is wrong.

Try a different availability domain index or x86_64 image.

## Issabel Installer Fails

Check architecture:

```bash
uname -m
```

Expected: `x86_64`.

Check memory:

```bash
free -h
swapon --show
```

If memory is tight, increase `swap_size_gb` or use a larger trial-credit VM during installation.

## Web GUI Is Unreachable

On the VM:

```bash
systemctl status httpd --no-pager
firewall-cmd --list-all
ss -tulpn | grep -E ':80|:443'
```

In OCI, confirm ports `80/tcp` and `443/tcp` are allowed from your current IP.

## SIP Phones Cannot Register

On the VM:

```bash
asterisk -rx "pjsip show endpoints"
asterisk -rx "pjsip show contacts"
tail -f /var/log/asterisk/messages
```

Check:

- Correct username and auth username.
- Correct generated password.
- SIP allowed CIDR includes the client public IP.
- Client transport is UDP.
- PJSIP config exists at `/etc/asterisk/pjsip_custom.conf`.

## Calls Work But Audio Is Missing

Usually this is RTP/NAT.

Check:

- OCI allows `10000-20000/udp` from the client/VPN CIDR.
- Firewalld allows the same range.
- `asterisk_public_ip` or `asterisk_external_host` is set when using public clients.
- The client codec includes ulaw or alaw.

Commands:

```bash
asterisk -rx "rtp set debug on"
tcpdump -ni any udp portrange 10000-20000
```

Disable RTP debug after testing:

```bash
asterisk -rx "rtp set debug off"
```

## IVR Does Not Play Audio

The lab uses built-in Asterisk sounds. Confirm sound packages exist:

```bash
ls /var/lib/asterisk/sounds/en
```

If missing, install Asterisk sound packages from the Issabel repositories.

## Call Recording Missing

Check directory ownership:

```bash
ls -ld /var/spool/asterisk/monitor
asterisk -rx "core show channels"
```

The directory should be writable by `asterisk`.

## CDR Missing

Check CSV module:

```bash
asterisk -rx "module show like cdr"
asterisk -rx "cdr show status"
ls -lah /var/log/asterisk/cdr-csv
```

If `Master.csv` is missing, reload Asterisk and place another call.

## Fail2Ban Blocks You

Show bans:

```bash
fail2ban-client status asterisk
fail2ban-client status sshd
```

Unban:

```bash
fail2ban-client unban <IP_ADDRESS>
```

Then add your IP to `fail2ban_ignoreip` in `ansible/group_vars/issabel.yml` and rerun the install playbook.

## Monitoring Fails

Check containers:

```bash
cd monitoring
docker compose ps
docker compose logs prometheus
docker compose logs grafana
```

Check metrics:

```bash
curl -s http://127.0.0.1:9100/metrics | head
curl -s http://127.0.0.1:9100/metrics | grep asterisk_
```

## Useful Commands

```bash
/usr/local/sbin/healthcheck.sh
systemctl status asterisk --no-pager
journalctl -u asterisk -n 100 --no-pager
asterisk -rvvv
asterisk -rx "core reload"
asterisk -rx "pjsip reload"
asterisk -rx "pjsip show contacts"
asterisk -rx "dialplan show from-internal-lab"
```
