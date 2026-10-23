# terraform-ibm-vpc-standard

Terraform module that provisions a standard IBM Cloud VPC network stack:
VPC · Subnet · Public Gateway · Security Group (SSH + ICMP inbound, all outbound).

Used as the network foundation for the `terraform-ibm-payments-dev` workspace.

---

## Usage

```hcl
module "vpc" {
  source = "github.com/<your-username>/terraform-ibm-vpc-standard?ref=v1.0.0"

  name   = "payments"
  region = "us-south"
  zone   = "us-south-1"
}
```

Or from your HCP Terraform private registry (once published):

```hcl
module "vpc" {
  source  = "app.terraform.io/<your-org>/vpc-standard/ibm"
  version = "1.0.0"

  name   = "payments"
  region = "us-south"
  zone   = "us-south-1"
}
```

> **Registry source casing:** HCP Terraform may store the provider as `IBM` (uppercase) but Terraform's parser requires it to be lowercase (`ibm`) in the `source` field. If you get `invalid target system "IBM"`, use the GitHub source form above instead.

---

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.9 |
| IBM-Cloud/ibm | ~> 1.77 |

---

## Inputs

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `name` | `string` | — | ✅ | Base name prefix for all resources (`<name>-vpc`, `<name>-subnet`, etc.) |
| `region` | `string` | `"us-south"` | No | IBM Cloud region |
| `zone` | `string` | `"us-south-1"` | No | IBM Cloud zone within the region |
| `subnet_cidr` | `string` | `"10.240.0.0/24"` | No | IPv4 CIDR block for the subnet |
| `allow_ssh_cidr` | `string` | `"0.0.0.0/0"` | No | CIDR range allowed to reach port 22 |
| `resource_group_id` | `string` | `""` | No | IBM Cloud resource group ID (uses account default if empty) |
| `tags` | `list(string)` | `[]` | No | Tags to attach to all resources |

---

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | ID of the created VPC |
| `vpc_name` | Name of the created VPC |
| `subnet_id` | ID of the created subnet |
| `subnet_cidr` | CIDR block of the created subnet |
| `security_group_id` | ID of the created security group |
| `public_gateway_id` | ID of the created public gateway |
| `zone` | Zone where resources were created |

---

## Resources created

| Resource | Description |
|---|---|
| `ibm_is_vpc` | VPC |
| `ibm_is_subnet` | Subnet attached to the public gateway |
| `ibm_is_public_gateway` | Public gateway for outbound internet access |
| `ibm_is_security_group` | Security group attached to the subnet |
| `ibm_is_security_group_rule` × 3 | SSH (22) inbound · ICMP inbound · all outbound |

---

## Publishing to HCP Terraform private registry

See [`prerequisites/README.md`](../../README.md) Step 6 for full publishing instructions.

Quick reference:
```bash
git tag v1.0.0
git push origin v1.0.0
# Then: HCP Terraform → Registry → Publish → Module → GitHub → terraform-ibm-vpc-standard
```

The tag **must start with `v`** — `1.0.0` alone will cause `invalid ref` errors.
