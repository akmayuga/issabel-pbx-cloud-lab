# Free Publish Strategy

You have two different goals:

1. Publish the project online so people can see it in your portfolio.
2. Run a live Issabel PBX in the cloud.

The first one is truly free and easy. The second one is only free if you can get approved for a real VM provider or student/free credits.

## Best Free Path for Your Portfolio

Use GitHub Pages.

Why:

- Free for public repositories on GitHub Free.
- Publishes this project as a real public website.
- Does not need a VPS, credit card, or local device.
- Perfect for demos, resumes, project links, and school/client presentation.

Limitation:

- GitHub Pages is static hosting only. It cannot run Issabel, Asterisk, SIP, RTP, Docker, Terraform, or Ansible.

## Publish Steps with GitHub Pages

1. Create a GitHub repository, for example `issabel-pbx-cloud-lab`.
2. Push this local repository:

```bash
git remote add origin https://github.com/<YOUR_USERNAME>/issabel-pbx-cloud-lab.git
git add .
git commit -m "Initial Issabel PBX cloud lab"
git push -u origin main
```

3. In GitHub, open the repository.
4. Go to `Settings -> Pages`.
5. Under `Build and deployment`, choose `Deploy from a branch`.
6. Set branch to `main` and folder to `/docs`.
7. Click `Save`.
8. Your public demo URL will look like:

```text
https://<YOUR_USERNAME>.github.io/issabel-pbx-cloud-lab/
```

The public homepage is:

```text
docs/index.html
```

## Best Free Path for a Live PBX

A live Issabel PBX needs:

- VM/root access
- Public IPv4 or reachable VPN
- UDP `5060`
- UDP `10000-20000`
- Persistent disk
- Systemd services
- Firewall and Fail2Ban

Static/app hosts usually cannot provide this.

## Free Live PBX Options

### Option A: Oracle Cloud Free Tier

Best technical fit, but your signup is currently blocked. If Oracle approves your account later, use the existing Terraform path in this repo.

### Option B: Azure for Students

Best no-credit-card option if you are eligible.

Use this if:

- You have a valid school email.
- You can get Azure for Students credit.
- You can create a Linux VM with public IPv4.

Notes:

- Microsoft advertises Azure for Students with credit and no credit card.
- You still need to watch quotas and stop/delete resources when done.
- This repo does not yet include Azure Terraform, but the Ansible scripts can still configure the VM after you create one.

### Option C: Google Cloud Free Tier

Possible, but it usually requires billing verification.

Use this if:

- Google accepts your payment method.
- You use the e2-micro Always Free VM in eligible regions.
- You accept that Issabel may be slow on e2-micro.

Recommended only for a lightweight demo. Add swap.

### Option D: AWS Free Tier

Possible for eligible accounts, but not permanent free for most new setups.

Use this if:

- Your account is eligible for EC2 Free Tier/credits.
- You set AWS Budgets immediately.
- You delete resources after demos.

## Not Suitable for Live Issabel

These can host project pages or web apps, but not a full PBX:

- GitHub Pages
- Render free web services
- Railway
- Fly.io app hosting
- Netlify
- Vercel
- Cloudflare Pages

Reason: Issabel needs system services and SIP/RTP UDP media networking.

## Recommended Demo Plan

Use this for zero cost:

1. Publish the portfolio/demo website on GitHub Pages.
2. Add screenshots, architecture diagrams, and call test docs.
3. Record a local or temporary-cloud demo video when you have access to a VM.
4. Link the video from `docs/index.html`.
5. Keep the real PBX deployment scripts in the repo as proof of implementation.

This lets you present the project anywhere without carrying a device and without paying for always-on compute.

## Sources

- GitHub Pages documentation: https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages
- Azure for Students: https://azure.microsoft.com/en-us/free/students
- Google Compute Engine free tier: https://cloud.google.com/compute
- AWS EC2 Free Tier usage: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-free-tier-usage.html
