variable "google_zone" {
  description = "For provider"
}

variable "google_region" {
  #type    = list(string)
  description = "For Node Pool"
}

variable "purestorage_env" {
   description = "Enter the Purestorage Environment name (dev, stg, tst, prd):"
   default = "dev"
}

variable "google_cloud_project_id" {
   description = "Enter the Purestorage Environment name (dev, stg, tst, prd):"
   default = "purestorage-gke"
}

variable "gcloud_iam_file_location" {
   description = "Enter the Google Cloud key secret location"
}

variable "compute_engine_service_account" {
   description = "Enter the Google Cloud service account for SSHing into Node instances"
}

variable "gke_machine_type" {
   description = "Please enter the GKE machine type for nodes to run on"
}

variable "gke_machine_image" {
   description = "Please enter the GKE machine AMI for kubernetes nodes to run on"
}

variable "number_of_nodes" {
   description = "Enter number of nodes you want to run for this Node in the EKS cluster"
}

variable "cluster_name" {
   description = "Enter the cluster name"
}

variable "k8s_version" {
   description = "Kubernetes version to install, Ex: 1.21"
}

variable "px_operator_version" {
   description = "Enter Px Operator Version to be installed, Ex: 1.6.1"
}

variable "px_storage_cluster_version" {
   description = "Enter Px Storage Cluster Version to be installed, Ex: 2.9.0"
}

variable "px_cloud_storage_type" {
   default = "gp2"
   description = "Enter the portworx storage type gp2/ssd"
}

variable "px_cloud_storage_size" {
   default  = "50"
   description = "Enter the size of the Px Storage (in GB)"
}

variable "px_kvdb_device_storage_type" {
   default = "gp2"
   description = "Enter the portworx kvdb device storage type gp2/ssd"
}

variable "px_kvdb_device_storage_size" {
   default  = "50"
   description = "Enter the size of the kvdb storage device (in GB)"
}


