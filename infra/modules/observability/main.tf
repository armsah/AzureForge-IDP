resource "azurerm_application_insights_workbook" "this" {
  name                = uuidv5("url", "azureforge://${var.container_app_id}/workbook")
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = var.workbook_name
  source_id           = lower(var.container_app_id)
  category            = "workbook"

  description = "AzureForge default observability workbook for ${var.container_app_name}."

  data_json = jsonencode({
    version = "Notebook/1.0"

    items = [
      {
        type = 1
        content = {
          json = "# ${var.container_app_name} observability\n\nAzureForge default service observability dashboard."
        }
        name = "service-heading"
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "ContainerAppConsoleLogs_CL | where ContainerAppName_s == '${var.container_app_name}' | summarize LogEntries=count() by bin(TimeGenerated, 5m) | order by TimeGenerated asc"
          size    = 0
          title   = "Container App log volume"
          timeContext = {
            durationMs = 3600000
          }
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          resourceIds  = [var.log_analytics_workspace_id]
        }
        name = "log-volume"
      },
      {
        type = 3
        content = {
          version = "MetricsItem/2.0"
          size    = 0
          chartId = "workbook-requests"
          title   = "Container App requests"
          timeContext = {
            durationMs = 3600000
          }
          resourceType  = "microsoft.app/containerapps"
          resourceIds   = [var.container_app_id]
          visualization = "timechart"
          metrics = [
            {
              namespace   = "microsoft.app/containerapps"
              metric      = "Requests"
              aggregation = 1
            }
          ]
        }
        name = "requests"
      },
      {
        type = 3
        content = {
          version = "MetricsItem/2.0"
          size    = 0
          chartId = "workbook-restarts"
          title   = "Container restart count"
          timeContext = {
            durationMs = 3600000
          }
          resourceType  = "microsoft.app/containerapps"
          resourceIds   = [var.container_app_id]
          visualization = "timechart"
          metrics = [
            {
              namespace   = "microsoft.app/containerapps"
              metric      = "RestartCount"
              aggregation = 1
            }
          ]
        }
        name = "restarts"
      }
    ]

    isLocked = false

    fallbackResourceIds = [
      var.container_app_id
    ]
  })

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "http_5xx" {
  count = var.alert_policy == "standard" ? 1 : 0

  name                = "alert-${var.container_app_name}-http-5xx"
  resource_group_name = var.resource_group_name
  scopes              = [var.container_app_id]

  description = "AzureForge standard alert: Container App returned HTTP 5xx responses."
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"
  enabled     = true

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "statusCodeCategory"
      operator = "Include"
      values   = ["5xx"]
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "container_restarts" {
  count = var.alert_policy == "standard" ? 1 : 0

  name                = "alert-${var.container_app_name}-restarts"
  resource_group_name = var.resource_group_name
  scopes              = [var.container_app_id]

  description = "AzureForge standard alert: Container App restart count exceeded the baseline."
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"
  enabled     = true

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "RestartCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 2
  }

  tags = var.tags
}
