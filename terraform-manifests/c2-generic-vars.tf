# Generic Variables for Terraform Provisioning

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = group1_wp_deployment_rg
}

variable "resource_group_location" {
  description = "Location of Resource Group"
  type        = string
  default     = "centralus"
}