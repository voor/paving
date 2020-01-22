resource "azurerm_role_definition" "pks-master" {
  count = 0
}

resource "azurerm_role_definition" "pks-worker" {
  count = 0
}

resource "azurerm_user_assigned_identity" "pks-master" {
  count = 0
}

resource "azurerm_role_assignment" "pks-master" {
  count              = 0
  role_definition_id = ""
  principal_id       = ""
}

resource "azurerm_user_assigned_identity" "pks-worker" {
  count = 0
}

resource "azurerm_role_assignment" "pks-worker" {
  count              = 0
  role_definition_id = ""
  principal_id       = ""
}
