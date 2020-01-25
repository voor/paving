resource "azurerm_public_ip" "harbor-lb" {
  name                = "${var.environment_name}-harbor-lb-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(
    var.tags,
    { name = "${var.environment_name}-harbor" },
  )
}

resource "azurerm_lb" "harbor" {
  name                = "${var.environment_name}-harbor-lb"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.platform.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.harbor-lb.name
    public_ip_address_id = azurerm_public_ip.harbor-lb.id
  }


  tags = merge(
    var.tags,
    { name = "${var.environment_name}-harbor" },
  )
}

resource "azurerm_lb_backend_address_pool" "harbor-lb" {
  name                = "${var.environment_name}-harbor-backend-pool"
  resource_group_name = azurerm_resource_group.platform.name
  loadbalancer_id     = azurerm_lb.harbor.id
}

resource "azurerm_lb_probe" "harbor-lb-tls" {
  name                = "${var.environment_name}-harbor-lb-tls-health-probe"
  resource_group_name = azurerm_resource_group.platform.name
  loadbalancer_id     = azurerm_lb.harbor.id
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
  port                = 443
}

resource "azurerm_lb_rule" "harbor-lb-tls" {
  name                           = "${var.environment_name}-harbor-lb-tls-rule"
  resource_group_name            = azurerm_resource_group.platform.name
  loadbalancer_id                = azurerm_lb.harbor.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_public_ip.harbor-lb.name
  probe_id                       = azurerm_lb_probe.harbor-lb-tls.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.harbor-lb.id
}

resource "azurerm_application_security_group" "harbor-api" {
  name                = "${var.environment_name}-harbor-api-app-sec-group"
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_network_security_group" "harbor-api" {
  name                = "${var.environment_name}-harbor-api-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name

  security_rule {
    name                                       = "api"
    priority                                   = 100
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_ranges                    = ["443"]
    source_address_prefix                      = "*"
    destination_application_security_group_ids = [azurerm_application_security_group.harbor-api.id]
  }
}

resource "azurerm_private_dns_a_record" "harbor" {
  name                = "harbor"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = "60"
  records             = [azurerm_public_ip.pks-lb.ip_address]

  tags = merge(
    var.tags,
    { name = "pks.${var.environment_name}" },
  )
}