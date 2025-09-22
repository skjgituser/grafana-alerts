terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.0"
    }
  }
}

provider "grafana" {
  url  = "https://singhaishobhit94.grafana.net/"  # <-- change this
  auth = var.grafana_api_key
}

# Contact point for alerts
resource "grafana_contact_point" "email" {
  name = "default-email"

  email {
    addresses = ["singhaishobhit94@gmail.com"]   # <-- change this
  }
}

# Root notification policy
resource "grafana_notification_policy" "root" {
  group_by      = ["ExampleAlert"]   # required
  contact_point = grafana_contact_point.email.name
}

# Rule group with a simple alert
resource "grafana_rule_group" "cpu_alert_group" {
  name             = "system-alerts"
  folder_uid       = "general"    # "general" is UID of the default folder
  interval_seconds = 60           # run every 60s

  rule {
    name      = "High CPU Usage"
    condition = "A > 80"

    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = "grafanacloud-prom"   # <-- replace with your real datasource UID
      model = jsonencode({
        expr    = "avg(rate(node_cpu_seconds_total{mode=\"user\"}[5m])) * 100"
        format  = "time_series"
        instant = true
      })
    }
  }
}
