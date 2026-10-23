# ------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------
resource "ibm_is_vpc" "main" {
  name           = "${var.name}-vpc"
  resource_group = var.resource_group_id != "" ? var.resource_group_id : null
  tags           = var.tags
}

# ------------------------------------------------------------------
# Public Gateway  (enables outbound internet from the subnet)
# ------------------------------------------------------------------
resource "ibm_is_public_gateway" "main" {
  name           = "${var.name}-pgw"
  vpc            = ibm_is_vpc.main.id
  zone           = var.zone
  resource_group = var.resource_group_id != "" ? var.resource_group_id : null
  tags           = var.tags
}

# ------------------------------------------------------------------
# Subnet
# ------------------------------------------------------------------
resource "ibm_is_subnet" "main" {
  name            = "${var.name}-subnet"
  vpc             = ibm_is_vpc.main.id
  zone            = var.zone
  ipv4_cidr_block = var.subnet_cidr
  public_gateway  = ibm_is_public_gateway.main.id
  resource_group  = var.resource_group_id != "" ? var.resource_group_id : null
  tags            = var.tags
}

# ------------------------------------------------------------------
# Security Group
# ------------------------------------------------------------------
resource "ibm_is_security_group" "main" {
  name           = "${var.name}-sg"
  vpc            = ibm_is_vpc.main.id
  resource_group = var.resource_group_id != "" ? var.resource_group_id : null
  tags           = var.tags
}

# Allow inbound SSH
resource "ibm_is_security_group_rule" "ssh_inbound" {
  group     = ibm_is_security_group.main.id
  direction = "inbound"
  remote    = var.allow_ssh_cidr
  protocol  = "tcp"
  port_min  = 22
  port_max  = 22
}

# Allow inbound ICMP (ping)
resource "ibm_is_security_group_rule" "icmp_inbound" {
  group     = ibm_is_security_group.main.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "icmp"
}

# Allow all outbound
resource "ibm_is_security_group_rule" "all_outbound" {
  group     = ibm_is_security_group.main.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
