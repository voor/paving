resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "${var.environment_name}-logs"
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = var.tags
}