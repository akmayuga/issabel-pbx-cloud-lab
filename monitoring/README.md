# Monitoring Stack

This folder runs Prometheus, Grafana, and Node Exporter with Docker Compose on the PBX VM.

## Metrics Covered

- CPU: Node Exporter.
- Memory: Node Exporter.
- Disk: Node Exporter.
- Asterisk service status: `asterisk_service_up` textfile metric.
- PJSIP registrations: `asterisk_pjsip_registered_contacts` textfile metric.

## Deploy

```bash
cd monitoring
GRAFANA_ADMIN_PASSWORD='replace-this' docker compose up -d
```

## Validate

```bash
docker compose ps
curl -s http://127.0.0.1:9100/metrics | grep -E 'node_memory|node_cpu|node_filesystem|asterisk_'
```

## Access

- Grafana: `http://<PBX_IP>:3000`
- Prometheus: `http://<PBX_IP>:9090`

Restrict both ports to your admin IP or use SSH tunneling:

```bash
ssh -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 opc@<PBX_IP>
```

Then use:

- Grafana: `http://127.0.0.1:3000`
- Prometheus: `http://127.0.0.1:9090`
