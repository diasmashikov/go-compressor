# Cloud Armor security policy (WAF + Rate Limiting)
resource "google_compute_security_policy" "main" {
  name = "api-security-policy"

  # Rate limiting rule
  rule {
    action   = "rate_based_ban"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      rate_limit_threshold {
        count        = 30  # 100 requests
        interval_sec = 60   # per minute
      }
      ban_duration_sec = 600
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
    }
    description = "Rate limiting per IP"
  }

  # Default rule
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

# Firewall rules
resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  target_tags = ["go-server"]
}

resource "google_compute_firewall" "allow_lb" {
  name    = "allow-lb"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [
    "34.96.0.0/20",
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  target_tags = ["go-server"]
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "go-ssl-cert"

  managed {
    domains = [var.domain_name]
  }

  lifecycle {
    prevent_destroy = true
  }
}
