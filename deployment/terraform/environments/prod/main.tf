terraform {
  backend "local" {
    path = "../terraform_storage/terraform.tfstate"
  }
}

provider "google" {
  project     = var.project_id
  credentials = file(var.credentials_file)
  region      = var.region
  zone        = var.zone
}

module "api_infrastructure" {
  source           = "../../modules/api_infrastructure"
  project_id       = var.project_id
  region           = var.region
  credentials_file = file(var.credentials_file)
  zone             = var.zone
  domain_name      = var.domain_name
  docker_image     = var.docker_image
  alert_email      = var.alert_email
}