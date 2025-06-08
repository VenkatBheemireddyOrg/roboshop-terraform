resource "grafana_folder" "main" {
  depends_on = [helm_release.prometheus, helm_release.external-dns]
  title = "node-exporters"
  uid   = "node-exporters"
}

resource "grafana_dashboard" "main" {
  folder = grafana_folder.main.uid
  config_json = file("${path.module}/grafana-dashboards/node-exporter.json")
}

terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
    }
  }
}