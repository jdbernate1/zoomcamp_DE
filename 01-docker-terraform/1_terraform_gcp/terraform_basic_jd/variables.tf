variable "credentials" {
  default     = "C:/Users/JuanDiego/Documents/data-engineering-zoomcamp/01-docker-terraform/1_terraform_gcp/keys/my_creds.json"
  description = "Credentials path"
}


variable "project" {
  type        = string
  default     = "dezoomcampjdbv"
  description = "Project"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Region"
}



variable "location" {
  default     = "US"
  description = "Project Location"
}

variable "bq_dataset_name" {
  default     = "demo_dataset"
  description = "My Bigquery Dataset"
}

variable "gcs_storage_class" {
  default     = "STANDAR"
  description = "Bucket Storage Class"
}

variable "gcs_bucket_name" {
  default     = "dezoomcampjdbv-terra-bucket"
  description = "Bucket Storage Class"
}
