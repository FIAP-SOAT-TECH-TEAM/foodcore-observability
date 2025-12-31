locals {
  repository_url = "oci://${data.azurerm_container_registry.acr.login_server}/helm"
}