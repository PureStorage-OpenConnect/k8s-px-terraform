region                       = "aws_region_id"
number_of_nodes              = "4"
ec2_instance_type            = "c5a.xlarge"
purestorage_aws_keypair      = "<Enter your keypair>"
cluster_name                 = "<Enter your custom cluster name>"     //The name must be unique across all regions. Cluster name cannot exceed 25 characters
k8s_version                  = "1.21"

# Portworx Specific
px_operator_version          = "1.6.1"
px_storage_cluster_version   = "2.9.0" 
px_cloud_storage_type        = "gp2"
px_cloud_storage_size        = "30"
px_kvdb_device_storage_type  = "gp2"
px_kvdb_device_storage_size  = "40"
