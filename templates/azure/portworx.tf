resource "null_resource" "install_portworx" {
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG="$PWD/kube-config-file"
      if [ -f ~/.kube/config ]; then
         mv ~/.kube/config ~/.kube/config_$(date +%F_%H-%M-%S)
      fi
      sleep 30
      az aks get-credentials -n ${var.cluster_name} --resource-group "px-${var.resource_group}"
      mkdir -p ~/.kube
      cp $PWD/kube-config-file ~/.kube/aks_${var.cluster_name}
      sleep 5
      kubectl create namespace portworx
      kubectl create secret generic -n portworx px-azure \
             --from-literal=AZURE_TENANT_ID="${var.tenant_id}" \
             --from-literal=AZURE_CLIENT_ID="${var.app_id}" \
             --from-literal=AZURE_CLIENT_SECRET="${var.service_principle_key}"
      chmod +x "../../../../scripts/aks/installPortworx.sh"
      "../../../../scripts/aks/installPortworx.sh" \
         "${var.px_operator_version}" \
         "${var.px_storage_cluster_version}" \
         "${var.px_cloud_storage_type}" \
         "${var.px_cloud_storage_size}" \
         "${var.px_kvdb_device_storage_type}" \
         "${var.px_kvdb_device_storage_size}" 

     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
}
  
  depends_on = [module.aks]
}

resource "null_resource" "remove_portworx" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Removing portworx, it will take several minutes."
      ../../../../scripts/aks/removePortworx.sh
    EOT
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
  depends_on = [module.aks]
}
