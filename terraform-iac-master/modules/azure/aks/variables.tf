variable "resource_group" {
   description = "Enter Resource Group Name to create"
   default = "demo_resource_group" 
}

variable "kubernetes_version" {
    default = "1.16.10"
}

variable cluster_name {
  description = "Holds Cluster Name"
  default = "ps-demo"
}

variable location {
  description = "Provide region"
}

variable "serviceprinciple_id" {
  description = "Enter Azure Principle Id:"
}

variable "serviceprinciple_key" {
   description = "Enter Azure Principle Key:"
}

variable "ssh_key" {
   description = "Enter the SSH key for the nodes in the K8 cluster"
}

variable "number_of_nodes" {
   description = "Please enter the number of nodes in the Kubernetes Cluster:"
}

variable "azure_instance_type" {
   description = "Choose the Azure Instance Type:"
}

