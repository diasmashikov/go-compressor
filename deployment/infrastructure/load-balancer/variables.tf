variable "project_id" {
  description = "The Google Cloud project ID"
}

variable "credentials_file" {
  description = "Path to the service account credentials file"
}

variable "region" {
  description = "The region for GCP resources"
}

variable "zone" {
  description = "The zone for GCP resources"
}

variable "docker_image" {
  description = "The docker image to pull & deploy our app"
}
