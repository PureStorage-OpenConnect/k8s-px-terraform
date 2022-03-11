terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.31.1"
    }
  }
}

# Provides configuration details for the Azure Terraform Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.service_principle_id
  client_secret   = var.service_principle_key
  tenant_id       = var.tenant_id
  

  features {}
}


