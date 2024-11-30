# Load Balancer components
resource "google_compute_backend_service" "go-backend-service" {
  name          = "go-backend-service"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 40
  health_checks = [google_compute_health_check.go-health-check.self_link]
  security_policy = google_compute_security_policy.main.id  # Link to Cloud Armor

  backend {
    group = google_compute_instance_group_manager.go-server-mig.instance_group
  }
}

# URL map
resource "google_compute_url_map" "go-url-map" {
  name            = "go-url-map"
  default_service = google_compute_backend_service.go-backend-service.self_link
}

# HTTP proxy (for redirect)
resource "google_compute_target_http_proxy" "go-http-proxy" {
  name    = "go-http-proxy"
  url_map = google_compute_url_map.go-url-map.self_link
}

# HTTPS proxy
resource "google_compute_target_https_proxy" "go-https-proxy" {
  name             = "go-https-proxy"
  url_map          = google_compute_url_map.go-url-map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.default.self_link]
}

# Static IP
resource "google_compute_global_address" "static_ip" {
  name = "lb-global-static-ip"
}


# HTTP Forwarding rule (for redirect)
resource "google_compute_global_forwarding_rule" "go-http-forwarding-rule" {
  name       = "go-http-forwarding-rule"
  target     = google_compute_target_http_proxy.go-http-proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.static_ip.address
}

# HTTPS Forwarding rule
resource "google_compute_global_forwarding_rule" "go-https-forwarding-rule" {
  name       = "go-https-forwarding-rule"
  target     = google_compute_target_https_proxy.go-https-proxy.self_link
  port_range = "443"
  ip_address = google_compute_global_address.static_ip.address
}
