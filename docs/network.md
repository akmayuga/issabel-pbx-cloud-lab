# Network Diagram

```mermaid
graph TD
    Admin[Admin Workstation]
    Phone1[Softphone 1001]
    Phone2[Softphone 1002]
    WG[WireGuard tunnel optional]
    PublicIP[OCI Public IP]
    SL[OCI Security List]
    FW[VM firewalld]
    PBX[Issabel / Asterisk]
    Mon[Grafana + Prometheus]

    Admin -->|SSH 22, HTTPS 443, Grafana 3000, Prometheus 9090| SL
    Phone1 -->|SIP 5060, RTP 10000-20000| SL
    Phone2 -->|SIP 5060, RTP 10000-20000| SL
    Phone1 -.-> WG
    Phone2 -.-> WG
    WG --> PublicIP
    SL --> PublicIP
    PublicIP --> FW
    FW --> PBX
    FW --> Mon
```

## Port Plan

| Port | Protocol | Purpose | Recommended source |
|---:|---|---|---|
| 22 | TCP | SSH | Admin IP only |
| 80 | TCP | HTTP and ACME | Admin IP, temporarily public for Let's Encrypt if needed |
| 443 | TCP | Issabel HTTPS | Admin IP or VPN |
| 5060 | UDP/TCP | SIP signaling | Softphone IP or VPN only |
| 10000-20000 | UDP | RTP audio | Softphone IP or VPN only |
| 51820 | UDP | WireGuard | Admin/peer IP when possible |
| 3000 | TCP | Grafana | Admin IP or SSH tunnel |
| 9090 | TCP | Prometheus | Admin IP or SSH tunnel |
| 9100 | TCP | Node Exporter | Localhost only with current compose design |

## NAT Notes

Public cloud VoIP commonly fails because SIP signaling and RTP media advertise private addresses. Set one of these in `ansible/group_vars/issabel.yml`:

```yaml
asterisk_public_ip: "<PUBLIC_IP>"
```

or:

```yaml
asterisk_external_host: "pbx.example.com"
```

Also keep:

```yaml
asterisk_local_net: "10.60.0.0/16"
```

matching the Terraform VCN CIDR.
