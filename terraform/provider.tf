terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.88.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0" # https://github.com/hashicorp/terraform-provider-helm/issues/1689
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
  
  registry {
      url      = "oci://${data.azurerm_container_registry.acr.login_server}/helm"
      username = data.azurerm_container_registry.acr.admin_username
      password = data.azurerm_container_registry.acr.admin_password
  }
  
}