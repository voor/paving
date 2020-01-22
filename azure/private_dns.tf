resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.hosted_zone
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_link" {
  name                  = "${var.hosted_zone}-to-${azurerm_virtual_network.platform.name}"
  resource_group_name   = azurerm_resource_group.platform.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = azurerm_virtual_network.platform.id
}


resource "azurerm_private_dns_a_record" "ops-manager" {
  name                = "opsmanager"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = "60"
  records             = [azurerm_public_ip.ops-manager.ip_address]

  tags = merge(
    var.tags,
    { name = "opsmanager.${var.environment_name}" },
  )
}

resource "azurerm_private_dns_a_record" "apps" {
  name                = "*.apps"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = "60"
  records             = [azurerm_public_ip.web-lb.ip_address]

  tags = merge(
    var.tags,
    { name = "*.apps.${var.environment_name}" },
  )
}

resource "azurerm_private_dns_a_record" "sys" {
  name                = "*.sys"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = "60"
  records             = [azurerm_public_ip.web-lb.ip_address]

  tags = merge(
    var.tags,
    { name = "*.sys.${var.environment_name}" },
  )
}

resource "azurerm_private_dns_a_record" "ssh" {
  name                = "ssh.sys"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = "60"
  records             = [azurerm_public_ip.diego-ssh-lb.ip_address]

  tags = merge(
    var.tags,
    { name = "ssh.sys.${var.environment_name}" },
  )
}

resource "azurerm_private_dns_a_record" "mysql" {
  name                = "mysql"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = "60"
  records             = [azurerm_lb.mysql.private_ip_address]

  tags = merge(
    var.tags,
    { name = "mysql.${var.environment_name}" },
  )
}

resource "azurerm_private_dns_a_record" "tcp" {
  name                = "tcp"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = "60"
  records             = [azurerm_public_ip.tcp-lb.ip_address]

  tags = merge(
    var.tags,
    { name = "tcp.${var.environment_name}" },
  )
}

resource "azurerm_private_dns_a_record" "pks" {
  name                = "pks"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = "60"
  records             = [azurerm_public_ip.pks-lb.ip_address]

  tags = merge(
    var.tags,
    { name = "pks.${var.environment_name}" },
  )
}
