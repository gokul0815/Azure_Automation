terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.25.0"
    }
  }



  backend "azurerm" {
    subscription_id      = "c2f4d38d-cfea-4b37-8620-2dbd9b242c4e"
    resource_group_name  = "rg-tfstate-cac"
    storage_account_name = "ttesatfstatecac"
    container_name       = "state"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-pvaks-cac"
  location = "canadacentral"
}