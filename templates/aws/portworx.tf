resource "null_resource" "install_portworx" {
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG="$PWD/kube-config-file"
      if [ -f ~/.kube/config ]; then
         mv ~/.kube/config ~/.kube/config_$(date +%F_%H-%M-%S)
      fi
      sleep 30
      aws eks --region ${var.region} update-kubeconfig --name ${local.name}
      mkdir -p ~/.kube
      cp "$PWD/kube-config-file"  ~/.kube/eks_${local.name}
      sleep 5
      chmod +x "../../../../scripts/eks/installPortworx.sh"
      "../../../../scripts/eks/installPortworx.sh" \
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
  depends_on = [module.eks, module.vpc]
}
resource "null_resource" "remove_portworx" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Removing portworx, it will take several minutes."
      "../../../../scripts/eks/removePortworx.sh"
    EOT
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
  depends_on = [module.eks, module.vpc, null_resource.install_portworx]
}
