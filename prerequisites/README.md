# Prerequisites Setup Guide

Complete these steps **once** before running the lab. The lab assumes everything here is already in place.

---

## Checklist

- [ ] **Step 1** — Clone the lab repository
- [ ] **Step 2** — Generate an RSA SSH key pair
- [ ] **Step 3** — Create an HCP Terraform organization
- [ ] **Step 4** — Connect GitHub to HCP Terraform
- [ ] **Step 5** — Create the credentials variable set
- [ ] **Step 6** — Publish the `vpc-standard` module
- [ ] **Step 7** — Create and clone the workspace repository
- [ ] **Step 8** — Authenticate tfctl

---

## Step 1 — Clone the lab repository

```bash
git clone https://github.com/juruizra/bob-terraform-lab.git
cd bob-terraform-lab
```

---

## Step 2 — Generate an RSA SSH key pair

> **IBM Cloud note:** IBM Cloud VPC only accepts **RSA** keys. `ed25519` keys are rejected at apply time with `public key is not of type rsa`. Generate RSA regardless of your personal preference.

```bash
mkdir -p prerequisites/ssh-keys
ssh-keygen -t rsa -b 4096 \
  -C "payments-demo" \
  -f prerequisites/ssh-keys/payments-demo \
  -N ""
```

This creates:

```
prerequisites/ssh-keys/
├── payments-demo        ← private key (gitignored — never commit this)
└── payments-demo.pub    ← public key (passed to Bob as workspace variable)
```

To connect to the VSI after the lab:
```bash
ssh root@<public_ip> -i prerequisites/ssh-keys/payments-demo
```

---

## Step 3 — Create an HCP Terraform organization

1. Log in to [app.terraform.io](https://app.terraform.io)
2. Click **New organization** → choose a name (e.g. `my-lab-org`)
3. Note the organization name — Bob will ask you to confirm it

> The free tier is sufficient for this lab.

---

## Step 4 — Connect GitHub to HCP Terraform

HCP Terraform needs VCS access to your GitHub account to link workspaces to repositories.

**Recommended: GitHub App (no token expiry)**

1. In your org: `Settings → VCS Providers → Add VCS Provider → GitHub → GitHub App`
2. Follow the OAuth flow — authorize the GitHub App for your account
3. Note the installation ID format (`ghain-*`) — Bob detects this automatically

**Alternative: OAuth token**

1. `Settings → VCS Providers → Add VCS Provider → GitHub (Custom) → GitHub.com`
2. Create a GitHub OAuth App and paste the credentials
3. Note the token ID format (`ot-*`)

> Bob queries `/github-app/installations` and `/organizations/{org}/oauth-tokens` automatically to detect which method you configured — you don't need to tell Bob.

---

## Step 5 — Create the credentials variable set

This variable set injects your cloud credentials into every workspace that needs them.

1. In your org: `Settings → Variable Sets → Create variable set`
2. Name it `cloud-creds` (or any name — Bob will find it automatically)
3. Scope: **Apply to specific workspaces** (Bob will attach it during the lab)
4. Add the credential variable:

**IBM Cloud:**

| Key | Type | Value | Sensitive |
|---|---|---|---|
| `IC_API_KEY` | Environment variable | Your IBM Cloud API key | ✅ Yes |

To create an IBM Cloud API key with the right permissions:
1. Go to [cloud.ibm.com/iam/apikeys](https://cloud.ibm.com/iam/apikeys) → **Create**
2. The key needs: **VPC Infrastructure Services → Editor** (to create VSIs, subnets, floating IPs)
3. Copy the key value immediately — it is only shown once

**Other providers (reference):**

| Provider | Variable(s) |
|---|---|
| AWS | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` (+ optionally `AWS_DEFAULT_REGION`) |
| Azure | `ARM_CLIENT_ID` + `ARM_CLIENT_SECRET` + `ARM_SUBSCRIPTION_ID` + `ARM_TENANT_ID` |
| GCP | `GOOGLE_CREDENTIALS` (JSON key content) |

---

## Step 6 — Publish the `vpc-standard` module

The module source code is at [`prerequisites/modules/terraform-ibm-vpc-standard/`](modules/terraform-ibm-vpc-standard/).

### 6a — Create a GitHub repository for the module

Create a new **public** GitHub repository named exactly **`terraform-ibm-vpc-standard`**.

> HCP Terraform's private registry requires the repository to follow the naming convention `terraform-<provider>-<name>`.

### 6b — Push the module source

```bash
cd prerequisites/modules/terraform-ibm-vpc-standard

git init
git remote add origin https://github.com/<your-username>/terraform-ibm-vpc-standard.git
git add .
git commit -m "feat: initial vpc-standard module v1.0.0"
git branch -M main
git push -u origin main
```

### 6c — Tag the release

HCP Terraform uses git tags as module versions. The tag **must start with `v`**:

```bash
git tag v1.0.0
git push origin v1.0.0
```

> Common mistake: tagging `1.0.0` instead of `v1.0.0`. Bob verifies the exact tag with `git ls-remote --tags` and uses the `v`-prefixed form.

### 6d — Publish to HCP Terraform private registry

1. In your org: `Registry → Publish → Module → GitHub`
2. Select the `terraform-ibm-vpc-standard` repository
3. HCP Terraform detects the `v1.0.0` tag and publishes version `1.0.0`

Verify the module is available at:
```
app.terraform.io/<your-org>/vpc-standard/ibm    version 1.0.0
```

### Module reference

| Input | Default | Description |
|---|---|---|
| `name` | required | Base name prefix for all resources |
| `region` | `us-south` | IBM Cloud region |
| `zone` | `us-south-1` | IBM Cloud zone |
| `subnet_cidr` | `10.240.0.0/24` | Subnet CIDR |
| `allow_ssh_cidr` | `0.0.0.0/0` | CIDR allowed to reach port 22 |
| `resource_group_id` | `""` | IBM Cloud resource group (default if empty) |
| `tags` | `[]` | Tags for all resources |

| Output | Description |
|---|---|
| `vpc_id` | ID of the VPC |
| `subnet_id` | ID of the subnet |
| `security_group_id` | ID of the security group |
| `public_gateway_id` | ID of the public gateway |
| `zone` | Zone where resources were created |

Resources created by the module:
- `ibm_is_vpc`
- `ibm_is_subnet`
- `ibm_is_public_gateway`
- `ibm_is_security_group` with rules: SSH(22) inbound, ICMP inbound, all outbound

---

## Step 7 — Create and clone the workspace repository

Create a new **empty** GitHub repository named **`terraform-ibm-payments-dev`** (no README, no `.gitignore` — leave it completely empty).

Then clone it into the `live/` directory of this repo:

```bash
git clone https://github.com/<your-username>/terraform-ibm-payments-dev.git \
  live/terraform-ibm-payments-dev
```

> Bob detects this clone automatically by matching the `origin` URL. Do not rename the directory.

---

## Step 8 — Authenticate tfctl

tfctl is the CLI Bob uses to manage HCP Terraform resources:

```bash
brew install hashicorp/tap/tfctl
tfctl auth login
```

Follow the browser flow to authenticate with your HCP Terraform account.

Verify it works:
```bash
tfctl get organizations
```

You should see your organization listed.

---

## SSH key security

The `ssh-keys/` directory has a `.gitignore` that excludes private keys:

```
prerequisites/ssh-keys/
├── .gitignore           ← excludes files without .pub extension
├── payments-demo        ← NEVER commit (gitignored)
└── payments-demo.pub    ← safe to commit
```

**Never commit private key files.** If you accidentally commit one, rotate it immediately.
