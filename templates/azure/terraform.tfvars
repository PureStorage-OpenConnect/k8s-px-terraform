azure_location                 = "AZURE_LOCATION_ID" //eastus
resource_group                 = "demo-res-grp"      // prepends with px-

cluster_name                   = "px-test-cluster1"
k8s_version                    = "1.21.7"
azure_instance_type            = "standard_e4-2ds_v5"
number_of_nodes                = "3"

subscription_id                = "<Replace with your Azure subscription ID>"
service_principle_id           = "SvcPID"    //reads from az cli login user authentication
service_principle_key          = "SvcPKEY"   //reads from az cli login user authentication
tenant_id                      = "SvcTID"    //reads from az cli login user authentication
app_id                         = "SvcAPPID"  //reads from az cli login user authentication

px_operator_version            = "1.6.1"
px_kvdb_device_storage_type    = "Premium_LRS"
px_kvdb_device_storage_size    = "150"
px_cloud_storage_size          = "30"
px_cloud_storage_type          = "Premium_LRS"
px_storage_cluster_version     = "2.8.1.2"
