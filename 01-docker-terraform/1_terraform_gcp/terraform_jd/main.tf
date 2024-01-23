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
  project = "dezoomcampjdbv"
  region  = "us-central1"
}

resource "google_storage_bucket" "demo-bucket" { #demo-bucket define el nombre del elemento
  name          = "dezoomcampjdbv-terra-bucket"
  location      = "US"
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