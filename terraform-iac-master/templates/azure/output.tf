output "resource_group" {
   value = module.aks.resource_group_name
}

output "aks_cluster_name" {
   value = var.cluster_name
}

output "kubeconfig_refresh" {
   value = "az aks get-credentials -n ${var.cluster_name} --resource-group px-${var.resource_group}"
}

output "ssh_key" {
   value = "Local private pem Key file has been created for SSH to nodes"
}

output "ssh_pub_key" {
   value = tls_private_key.linux_ssh_key.public_key_openssh
}