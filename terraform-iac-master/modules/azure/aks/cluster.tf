resource "azurerm_resource_group" "ps-resource-group" {
  name     = "px-${var.resource_group}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "ps-aks-cluster" {
  name                  = var.cluster_name
  location              = azurerm_resource_group.ps-resource-group.location
  resource_group_name   = azurerm_resource_group.ps-resource-group.name
  dns_prefix            = var.cluster_name
  kubernetes_version    = var.kubernetes_version

  
  default_node_pool {
    name       = "pxnp${substr(lower(var.cluster_name), 0, 5)}"
    node_count = var.number_of_nodes
    vm_size    = var.azure_instance_type
    type       = "VirtualMachineScaleSets"
    os_disk_size_gb = 250
  }

  service_principal  {
    client_id = var.serviceprinciple_id
    client_secret = var.serviceprinciple_key
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
        key_data = var.ssh_key
    }
  }

  network_profile {
      network_plugin = "kubenet"
      load_balancer_sku = "Standard"
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled = false
    }
  }

}
