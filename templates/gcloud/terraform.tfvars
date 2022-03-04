google_cloud_project_id         = "px-project"
google_region                   = "google_region_replaceme"
google_zone                     = "google_region_replaceme-a"
number_of_nodes                 = "3"
gke_machine_type                = "e2-standard-2"
compute_engine_service_account  = "portworx-gke-cloud-operations@px-project.iam.gserviceaccount.com"
gcloud_iam_file_location        = "../../../../scripts/keys/px-final-test1-cluster-ops.json"
cluster_name                    = "ps-demo-one"
gke_machine_image               = "UBUNTU_CONTAINERD"
k8s_version                     = "1.21.6-gke.1503"
px_operator_version             = "1.6.1"
px_kvdb_device_storage_type     = "pd-ssd"
px_kvdb_device_storage_size     = "30"
px_cloud_storage_size           = "30"
px_cloud_storage_type           = "pd-ssd"
px_storage_cluster_version      = "2.9.0"
