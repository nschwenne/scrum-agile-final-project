# Generic Variables for Terraform Provisioning


variable "resource_group_name" {
  description = "Resource Group Name"
  type = string
  default = "group1_wp_deployment_rg"
}

variable "resource_group_location" {
  description = "Location of Resource Group"
  type = string
  default = "centralus"
}

variable "virtual_network_name" {
  description = "Name of Vnet"
  type = string
  default = "wordpress_client_vnet"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type = string
  default = "put me in a tfvars file"
}