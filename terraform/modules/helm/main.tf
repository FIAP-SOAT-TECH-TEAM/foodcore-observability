resource "helm_release" "foodcore_monitor" {
  name            = var.release_name
  repository      = var.repository_url
  chart           = var.chart_name
  version         = var.chart_version
  namespace       = var.release_namespace

  # Permitir upgrade e reinstalação do release automaticamente (apenas para fins da atividade)
  upgrade_install = true
  force_update    = true

  set {
    name  = "namespace.monitor.name"
    value = data.terraform_remote_state.infra.outputs.aks_monitor_namespace_name
  }

  set {
    name  = "namespace.order.name"
    value = data.terraform_remote_state.infra.outputs.aks_order_namespace_name
  }

  set {
    name  = "namespace.payment.name"
    value = data.terraform_remote_state.infra.outputs.aks_payment_namespace_name
  }

  set {
    name  = "namespace.catalog.name"
    value = data.terraform_remote_state.infra.outputs.aks_catalog_namespace_name
  }

  set {
    name  = "ingress.hosts[0].host"
    value = data.terraform_remote_state.infra.outputs.aks_ingress_public_ip_fqdn
  }

}