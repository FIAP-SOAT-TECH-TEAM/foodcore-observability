module "helm" {
  source = "./modules/helm"

  subscription_id                   = var.subscription_id
  foodcore-backend-container        = var.foodcore-backend-container
  foodcore-backend-infra-key        = var.foodcore-backend-infra-key
  foodcore-backend-resource-group   = var.foodcore-backend-resource-group
  foodcore-backend-storage-account  = var.foodcore-backend-storage-account
  release_name                      = var.release_name
  repository_url                    = local.repository_url
  chart_name                        = var.chart_name
  chart_version                     = var.chart_version
  release_namespace                 = var.release_namespace
}