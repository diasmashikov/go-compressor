terraform {
  backend "local" {
    path = "../terraform_storage/terraform.tfstate"
  }
}

# Provider configuration
provider "google" {
  project     = var.project_id
  credentials = file(var.credentials_file)
  region      = var.region
  zone        = var.zone
}


# Required services
resource "google_project_service" "required_services" {
  for_each = toset([
    "iam.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Service account for the instances
resource "google_service_account" "instance-sa" {
  account_id   = "instance-sa"
  display_name = "Service Account for VM instances"
  depends_on   = [google_project_service.required_services]
}

# IAM roles for the service account

resource "google_project_iam_member" "instance-sa-roles" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.instance-sa.email}"
}

# Instance template
resource "google_compute_instance_template" "go-server-template" {
  name        = "go-server-template"
  description = "Template for go servers"

  machine_type = "e2-micro"  # 2 vCPU, 1 GB RAM

  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
    type         = "pd-standard"
    disk_size_gb = 10
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.instance-sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
#!/bin/bash
export DOCKER_CONFIG=/home/chronos/.docker
mkdir -p $DOCKER_CONFIG
docker-credential-gcr configure-docker --registries="us-central1-docker.pkg.dev"
docker pull ${var.docker_image}
docker run -d \
  --name go-service \
  --restart always \
  -p 8080:8080 \
  ${var.docker_image}
EOF

  tags = ["go-server"]

  labels = {
    environment = "development"
    tier        = "free"
  }
}

# Managed Instance Group
resource "google_compute_instance_group_manager" "go-server-mig" {
  name = "go-server-mig"
  zone = "us-central1-a"

  version {
    instance_template = google_compute_instance_template.go-server-template.id
  }

  named_port {
    name = "http"
    port = 8080
  }

  base_instance_name = "go-server"

  target_size = 1  # Minimum number of instances
}

# Autoscaler
resource "google_compute_autoscaler" "go-server-autoscaler" {
  name   = "go-server-autoscaler"
  zone   = "us-central1-a"
  target = google_compute_instance_group_manager.go-server-mig.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 120

    cpu_utilization {
      target = 0.8  # Scale up when CPU utilization is above 70%
    }
  }
}

# Health check
resource "google_compute_health_check" "go-health-check" {
  name               = "go-health-check"
  timeout_sec        = 5
  check_interval_sec = 5

  http_health_check {
    port         = 8080
    request_path = "/health"
  }
}

# Backend service for instance group
resource "google_compute_backend_service" "go-backend-service" {
  name          = "go-backend-service"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.go-health-check.self_link]

  backend {
    group = google_compute_instance_group_manager.go-server-mig.instance_group
  }
}

# URL map
resource "google_compute_url_map" "go-url-map" {
  name            = "go-url-map"
  default_service = google_compute_backend_service.go-backend-service.self_link
}

# HTTP proxy
resource "google_compute_target_http_proxy" "go-http-proxy" {
  name    = "go-http-proxy"
  url_map = google_compute_url_map.go-url-map.self_link
}

# Static IP
resource "google_compute_address" "static_ip" {
  name = "lb-static-ip"
}

# Global forwarding rule
resource "google_compute_global_forwarding_rule" "go-forwarding-rule" {
  name       = "go-forwarding-rule"
  target     = google_compute_target_http_proxy.go-http-proxy.self_link
  port_range = "80"
  ip_address = google_compute_address.static_ip.address
}


# Firewall rule to allow health checks and HTTP traffic
resource "google_compute_firewall" "allow-health-check-and-http" {
  name    = "allow-health-check-and-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080", "80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "0.0.0.0/0"]
  target_tags   = ["go-server"]
}

# Output load balancer IP
output "load-balancer-ip" {
  value = google_compute_global_forwarding_rule.go-forwarding-rule.ip_address
}
