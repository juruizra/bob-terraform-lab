variable "name" {
  description = "Base name for all resources. Used as prefix: <name>-vpc, <name>-subnet, etc."
  type        = string
}

variable "region" {
  description = "IBM Cloud region where resources will be created."
  type        = string
  default     = "us-south"
}

variable "zone" {
  description = "IBM Cloud zone within the region."
  type        = string
  default     = "us-south-1"
}

variable "subnet_cidr" {
  description = "IPv4 CIDR block for the subnet."
  type        = string
  default     = "10.240.0.0/24"
}

variable "allow_ssh_cidr" {
  description = "CIDR range allowed to reach port 22 via SSH. Use 0.0.0.0/0 for public access."
  type        = string
  default     = "0.0.0.0/0"
}

variable "resource_group_id" {
  description = "ID of the IBM Cloud resource group. Defaults to the account default group if empty."
  type        = string
  default     = ""
}

variable "tags" {
  description = "List of tags to attach to all resources."
  type        = list(string)
  default     = []
}
