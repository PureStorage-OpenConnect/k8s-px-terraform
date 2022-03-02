output "gke-cluster-name" {
   value = var.cluster_name
}

output "gke-refresh-kube-config" {
   value = "gcloud container clusters get-credentials --region ${var.google_zone} ${var.cluster_name}"
}
