azure_location                 = "AZURE_LOCATION_ID" //eastus
resource_group                 = "demo-res-grp"      // prepends with px- Replace this value with your own resource group name

cluster_name                   = "px-test-cluster1"
k8s_version                    = "1.21.7"
azure_instance_type            = "standard_e4-2ds_v5"
number_of_nodes                = "3"

subscription_id                = "Subscription_ID"  //Reads from az cli login user authentication
service_principle_id           = "SvcPID"           //Reads from keys/service a/c file.
service_principle_key          = "SvcPKEY"          //Reads from keys/service a/c file.
tenant_id                      = "SvcTID"           //Reads from keys/service a/c file.
app_id                         = "SvcAPPID"         //Reads from keys/service a/c file.

px_operator_version            = "1.6.1"
px_kvdb_device_storage_type    = "Premium_LRS"
px_kvdb_device_storage_size    = "150"
px_cloud_storage_size          = "30"
px_cloud_storage_type          = "Premium_LRS"
px_storage_cluster_version     = "2.9.0"
