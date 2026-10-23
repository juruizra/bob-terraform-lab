output "vpc_id" {
  description = "ID of the created VPC."
  value       = ibm_is_vpc.main.id
}

output "vpc_name" {
  description = "Name of the created VPC."
  value       = ibm_is_vpc.main.name
}

output "subnet_id" {
  description = "ID of the created subnet."
  value       = ibm_is_subnet.main.id
}

output "subnet_cidr" {
  description = "CIDR block of the created subnet."
  value       = ibm_is_subnet.main.ipv4_cidr_block
}

output "security_group_id" {
  description = "ID of the created security group."
  value       = ibm_is_security_group.main.id
}

output "public_gateway_id" {
  description = "ID of the created public gateway."
  value       = ibm_is_public_gateway.main.id
}

output "zone" {
  description = "Zone where resources were created."
  value       = var.zone
}
