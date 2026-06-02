# Cost Optimization and Provider Comparison

Verified on 2026-06-01. Free tiers change, so confirm limits before deploying.

## Summary

| Provider | Fit for Issabel PBX | Free-cost reality | Notes |
|---|---:|---|---|
| Oracle Cloud Free Tier | Best | Always Free VM resources exist | Use x86_64 for Issabel 5. ARM A1 is generous but not compatible with current public Issabel media. |
| Google Cloud Free Tier | Limited | Always Free e2-micro in eligible regions | Good learning option, but tiny VM and low outbound allowance make PBX plus monitoring tight. |
| AWS Free Tier | Limited | EC2 free tier is time-limited for eligible accounts | Good short-term trial. Watch Elastic IP, storage, snapshots, and data transfer. |
| Fly.io | Poor | No general free account/free tier for new users | Great app platform, poor match for VM PBX and SIP/RTP. |
| Railway | Poor | Small monthly free credit/trial model | App PaaS, not a full VM PBX host. |
| Render | Poor | Free web/app services exist | Web-service platform, not suitable for privileged SIP/RTP PBX lab. |

## Recommendation

Use Oracle Cloud Infrastructure with the x86_64 AMD micro Always Free shape for a no-cost lab if you accept tight memory. Add swap and keep monitoring lightweight. If your OCI free trial credits are active, use a 2 GB or larger x86_64 VM for the install phase, then downsize only if the lab remains stable.

## Oracle Cloud Free Tier

Pros:

- Real VM, VCN, public IP, block volume, security list, and persistent storage.
- Always Free resources are suitable for infrastructure labs.
- Terraform provider is mature.

Constraints:

- The generous Ampere A1 Always Free resources are ARM.
- Issabel 5 public ISO/netinstall is x86_64, so use AMD/x86_64 for this repository.
- Always Free x86_64 micro resources are small. Use swap and avoid heavy dashboards.

## Google Cloud Free Tier

Pros:

- Real VM with Terraform support.
- Useful for Asterisk experiments.

Constraints:

- e2-micro is small for Issabel.
- Free outbound data allowance is limited.
- Some regions only.

## AWS Free Tier

Pros:

- Excellent VM and networking ecosystem.
- Good for short-term learning if your account is eligible.

Constraints:

- EC2 free tier is usually 12 months for eligible accounts.
- Easy to create billable storage, snapshots, Elastic IP usage, NAT gateways, and data transfer.
- Security groups must be tightly restricted for SIP.

## Fly.io

Not recommended for this lab. It is optimized for applications and Machines, not a full Issabel appliance with privileged system services, persistent PBX state, and broad UDP media ranges.

## Railway

Not recommended for this lab. Railway is excellent for app deployments but does not provide the full VM control, SIP/RTP networking model, or system service control this lab needs.

## Render

Not recommended for this lab. Render free services are useful for web workloads, not a PBX appliance with Asterisk, SIP, RTP, Fail2Ban, system firewalling, and host-level monitoring.

## Cost Guardrails

- Use Terraform variables to restrict ingress to your own IP.
- Do not create NAT gateways or load balancers.
- Delete unused boot volumes and snapshots.
- Keep monitoring retention small.
- Use `terraform destroy` when finished.
- Set cloud budget alerts before deployment.

## Sources

- Issabel 5 public files list shows `issabel5-USB-DVD-x86_64-20240430.iso` and `issabel5-netinstall.sh`: https://sourceforge.net/projects/issabelpbx/files/Issabel%205/
- OCI Always Free resources documentation: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm
- Google Compute Engine free tier information: https://cloud.google.com/compute
- AWS EC2 free tier usage documentation: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-free-tier-usage.html
- Fly.io pricing/cost-management docs: https://fly.io/docs/about/pricing/ and https://fly.io/docs/about/cost-management/
- Railway pricing docs: https://docs.railway.com/pricing
- Render free tier page: https://render.com/free
