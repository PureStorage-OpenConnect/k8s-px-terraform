# GKE cluster
resource "google_container_cluster" "primary" {
  name                    = var.cluster_name
  location                = var.google_zone
  min_master_version      = var.k8s_version
 
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  #network                  = google_compute_network.vpc.name
  #subnetwork               = google_compute_subnetwork.subnet.name

  release_channel {
    channel = "REGULAR"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [node_config, ip_allocation_policy, node_pool, initial_node_count, resource_labels["asmv"], resource_labels["mesh_id"]]
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.google_zone
  cluster    = google_container_cluster.primary.name
  node_count = var.number_of_nodes

  management {
    auto_repair = true
    auto_upgrade = true
  }

  node_config {
    preemptible             = true
    machine_type            = var.gke_machine_type
    disk_size_gb            = 50
    disk_type               = "pd-standard"
    image_type              = var.gke_machine_image
    service_account         = var.compute_engine_service_account

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.google_cloud_project_id
    }

    tags         = ["gke-node", "${var.google_cloud_project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
