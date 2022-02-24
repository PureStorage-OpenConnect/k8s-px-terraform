provider "google" {
   credentials = file(var.gcloud_iam_file_location)
   project     = var.google_cloud_project_id
   region      = var.google_region
}

