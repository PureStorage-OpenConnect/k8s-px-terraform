variable cluster_name {
  description = "Holds Cluster Name"
  default = "ps-demo"
}

variable azure_location {
  description = "Provide region"
}

variable "service_principle_id" {
  description = "Enter Azure Principle Id:"
}

variable "service_principle_key" {
   description = "Enter Azure Principle Key:"
}

variable "app_id" {
   description = "Enter Azure App Id:"
}

variable "tenant_id" {
   description = "Enter the Azure Tenant Id:"
}

variable "subscription_id" {
   description = "Enter the Azure Subscription Id"
}

variable "k8s_version" {
   description = "Enter the Kubernetes Cluster version to Provision"
}

variable "number_of_nodes" {
   description = "Please enter the number of nodes in the Kubernetes Cluster:"
}

variable "azure_instance_type" {
   description = "Choose the Azure Instance Type:"
}

variable "resource_group" {
   description = "Enter the resource_group"
}

variable "purestorage_env" {
   description = "Enter the Purestorage Environment name (dev, stg, tst, prd):"
   default = "dev"
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


