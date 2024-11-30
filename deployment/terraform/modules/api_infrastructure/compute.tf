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

# Instance Template to replicate as many instances of go-server as we need
resource "google_compute_instance_template" "go-server-template" {
  name        = "go-server-template"
  description = "Template for go servers"
  machine_type = "e2-micro"

  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
    type         = "pd-standard"
    disk_size_gb = 10
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id
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
  target_size        = 1
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
      target = 0.8
    }
  }
}
