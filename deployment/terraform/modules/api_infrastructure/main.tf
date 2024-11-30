# Setting GCP as our provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Getting required services to run our infrastructure
resource "google_project_service" "required_services" {
  for_each = toset([
    "iam.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "monitoring.googleapis.com",  
    "logging.googleapis.com"        
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Creating custom VPC to configure its security & access
resource "google_compute_network" "vpc" {
  name                    = "api-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# Creating a public subnet to allow a load balancer to accept incoming traffic
resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.id
  region        = var.region

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling       = 0.5
    metadata           = "INCLUDE_ALL_METADATA"
  }
}

# Creating a private subnet for our VMs & other services to communicate securely without exposure
resource "google_compute_subnetwork" "private" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.vpc.id
  region        = var.region
  private_ip_google_access = true
}

# Setting up a cloud router
resource "google_compute_router" "router" {
  name    = "api-router"
  network = google_compute_network.vpc.id
  region  = var.region
}

# Assigning a NAT router to allow private instances to communicate with external services like software installation, etc.
resource "google_compute_router_nat" "nat" {
  name                               = "api-nat"
  router                            = google_compute_router.router.name
  region                            = var.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  
  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
