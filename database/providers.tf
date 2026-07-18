terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
    random  = { source = "hashicorp/random",  version = "~> 3.6" }
    azapi = { source = "Azure/azapi", version = "~> 1.13" }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}
