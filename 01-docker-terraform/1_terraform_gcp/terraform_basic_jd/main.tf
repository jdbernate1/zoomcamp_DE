terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}


provider "google" {
  #credentials = "./keys/my_creds.json" #Esta es una opción, harcodear el path o usar gcloud para autenticar. Mientras uso en bash export GOOGLE_CREDENTIALS="path"
  credentials = file(var.credentials)
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "demo-bucket" { #demo-bucket define el nombre del elemento
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true



  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "demot_dataset" {
  dataset_id = var.bq_dataset_name
  location   = var.location
}