resource "azurerm_dns_a_record" "ops-manager" {
  count               = 0
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
}


resource "azurerm_dns_a_record" "apps" {
  count               = 0
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
}

resource "azurerm_dns_a_record" "sys" {
  count               = 0
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
}

resource "azurerm_dns_a_record" "ssh" {
  count               = 0
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
}

resource "azurerm_dns_a_record" "mysql" {
  count               = 0
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
}

resource "azurerm_dns_a_record" "tcp" {
  count               = 0
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
}

resource "azurerm_dns_a_record" "pks" {
  count               = 0
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
}


data "azurerm_dns_zone" "hosted" {
  count = 0
}
