# Contributing — Lab Reset and Repeat Guide

Instructions for resetting the lab to its initial state so it can be run again from scratch.

---

## What "reset" means

After a successful lab run, the following exist and must be cleaned up:

| What was created | Where | How to clean |
|---|---|---|
| Cloud resources (VSI, VPC, etc.) | Your cloud account | Terraform destroy via Bob or HCP Terraform UI |
| HCP Terraform workspace | `app.terraform.io` | Delete via tfctl or UI |
| Terraform files in `live/` | Local + GitHub | Remove files, commit, push |
| RSA SSH key | `prerequisites/ssh-keys/` | Delete (will be regenerated next run) |

---

## Step-by-step reset

### 1 — Destroy cloud resources

Ask Bob:

```
Trigger a destroy run on the terraform-ibm-payments-dev workspace.
```

Or from the HCP Terraform UI:
`Workspace → Settings → Destruction and Deletion → Queue destroy plan`

Wait until the destroy run reaches `applied` before continuing — deleting the workspace before the destroy completes will leave orphaned resources in your cloud account.

### 2 — Delete the HCP Terraform workspace

In your terminal (not Bob — workspace deletion requires interactive authorization):

```bash
tfctl api /workspaces/<workspace-id> -X DELETE
```

To get the workspace ID:
```bash
tfctl api /organizations/<your-org>/workspaces \
  --jq '.data[] | select(.attributes.name == "terraform-ibm-payments-dev") | .id'
```

Or delete from the UI: `Workspace → Settings → Destruction and Deletion → Delete workspace`.

### 3 — Remove Terraform files from GitHub

```bash
cd live/terraform-ibm-payments-dev
git rm -rf .
git commit -m "chore: reset lab"
git push
```

This empties the `main` branch in GitHub. The next lab run will push fresh files from scratch.

### 4 — Remove local Terraform files

```bash
rm -f live/terraform-ibm-payments-dev/terraform.tf \
      live/terraform-ibm-payments-dev/variables.tf \
      live/terraform-ibm-payments-dev/main.tf \
      live/terraform-ibm-payments-dev/outputs.tf \
      live/terraform-ibm-payments-dev/README.md
```

The directory itself stays — it must remain as a Git clone for Bob to detect it.

### 5 — Delete the RSA SSH key (optional)

The SSH key in `prerequisites/ssh-keys/` is re-generated automatically by Bob if the existing key is `ed25519`. If you want to force re-generation:

```bash
rm -f prerequisites/ssh-keys/payments-demo-rsa \
      prerequisites/ssh-keys/payments-demo-rsa.pub
```

If your key is already RSA (from a previous reset), Bob will reuse the existing `.pub` file — no need to delete it.

---

## Expected state before re-running the lab

| Item | Expected state |
|---|---|
| Workspace `terraform-ibm-payments-dev` | Does not exist in HCP Terraform |
| `live/terraform-ibm-payments-dev/` | Exists locally as a Git clone, no `.tf` files |
| `juruizra/terraform-ibm-payments-dev` on GitHub | `main` branch exists, no `.tf` files |
| `prerequisites/ssh-keys/` | Contains an RSA `.pub` file (or an `ed25519` key — Bob handles it) |
| Variable set with cloud credentials | Exists and attached to no workspaces |
| `vpc-standard` module in private registry | Still published — no need to re-publish |

Once this state is confirmed, open a new Bob chat and use the opening prompt from `README.md`.

---

## What is NOT reset

These items are one-time setup and do not need to be recreated between runs:

- HCP Terraform organization
- GitHub VCS connection (GitHub App or OAuth)
- Credentials variable set and its `IC_API_KEY` value
- The `vpc-standard` module in the private registry
- The `terraform-ibm-payments-dev` GitHub repository (it just gets emptied)
- The `live/terraform-ibm-payments-dev/` local clone
