resource "tls_private_key" "linux_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linux_pem_key" {
  filename = "${var.cluster_name}-sshkey.pem"
  content = tls_private_key.linux_ssh_key.private_key_pem
}

module "aks" {
  source                = "../../../../modules/azure/aks/"
  serviceprinciple_id   = var.service_principle_id
  serviceprinciple_key  = var.service_principle_key
  ssh_key               = tls_private_key.linux_ssh_key.public_key_openssh
  location              = var.azure_location
  kubernetes_version    = var.k8s_version
  number_of_nodes       = var.number_of_nodes
  azure_instance_type   = var.azure_instance_type
  cluster_name          = var.cluster_name
  resource_group        = var.resource_group
    
  depends_on = [
      tls_private_key.linux_ssh_key
  ]
}
