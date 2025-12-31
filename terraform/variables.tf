# Commn
  variable "subscription_id" {
    type        = string
    description = "Azure Subscription ID"
  }

# remote states
  variable "foodcore-backend-resource-group" {
    type        = string
    description = "Nome do resource group onde o backend está armazenado"
  }

  variable "foodcore-backend-storage-account" {
    type        = string
    description = "Nome da conta de armazenamento onde o backend está armazenado"
  }

  variable "foodcore-backend-container" {
    type        = string
    description = "Nome do contêiner onde o backend está armazenado"
  }

  variable "foodcore-backend-infra-key" {
    type        = string
    description = "Chave do arquivo tfstate do foodcore-infra"
  }

# HELM

  variable "release_name" {
    type        = string
    description = "Nome do release do Helm."
    default = "foodcore-observability"
  }

  variable "release_namespace" {
    type        = string
    description = "Namespace Kubernetes onde o release será instalado."
    default = "default"
  }

  variable "chart_name" {
    type        = string
    description = "Nome do chart Helm a ser instalado."
  }

  variable "chart_version" {
    type        = string
    description = "Versão do chart Helm."
  }