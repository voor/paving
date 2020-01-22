
resource "azurerm_dns_a_record" "ops-manager" {
  name = "opsmanager"
}

resource "azurerm_dns_a_record" "apps" {
  name = "*.apps"
}

resource "azurerm_dns_a_record" "sys" {
  name = "*.sys"
}

resource "azurerm_dns_a_record" "ssh" {
  name = "ssh.sys"
}

resource "azurerm_dns_a_record" "mysql" {
  name = "mysql"
}

resource "azurerm_dns_a_record" "tcp" {
  name = "tcp"
}

resource "azurerm_dns_a_record" "pks" {
  name = "pks"
}
