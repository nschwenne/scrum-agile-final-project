# Generic Variables for Terraform Provisioning

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "wp-client-rg"
}

variable "resource_group_location" {
  description = "Location of Resource Group"
  type        = string
  default     = "centralus"
}


variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "put me in a tfvars file"
}
