resource "azurerm_resource_group" "jmh" { name = var.resource_group_name; location = var.location }
resource "azurerm_kubernetes_cluster" "jmh" {
  name = var.cluster_name
  location = azurerm_resource_group.jmh.location
  resource_group_name = azurerm_resource_group.jmh.name
  dns_prefix = "jmhdevops"
  default_node_pool { name = "system"; node_count = 1; vm_size = "Standard_B2s" }
  identity { type = "SystemAssigned" }
  network_profile { network_plugin = "azure" }
}
