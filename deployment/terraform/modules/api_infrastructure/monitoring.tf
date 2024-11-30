# Allowing health checks for our load balancer's instances
resource "google_compute_health_check" "go-health-check" {
  name               = "go-health-check"
  timeout_sec        = 5
  check_interval_sec = 60

  http_health_check {
    port         = 8080
    request_path = "/health"
  }
}

# Monitoring whether our API is running externally
resource "google_monitoring_uptime_check_config" "api_health" {
  display_name = "api-health-check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path = "/health"
    port = "443"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.domain_name
    }
  }
}

# Alert Policy to see if anything is going wrong with the application
# resource "google_monitoring_alert_policy" "api_alerts" {
#   display_name = "API Critical Alerts"
#   combiner     = "OR" 
  
#   conditions {
#   display_name = "High Error Rate"
#   condition_threshold {
#     filter = "resource.type=\"loadbalancer_url_map\" AND metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND metric.labels.response_code_class=\"500\""
#     duration = "300s"
#     threshold_value = 10
#     comparison = "COMPARISON_GT"
#   }
# }

#   conditions {
#   display_name = "API Latency Too High"
#   condition_threshold {
#     filter = "resource.type=\"loadbalancer_url_map\" AND metric.type=\"loadbalancing.googleapis.com/https/total_latencies\""
#     duration = "120s"
#     threshold_value = 15000  # 15 seconds
#     comparison = "COMPARISON_GT"
#   }
# }

#   notification_channels = [google_monitoring_notification_channel.email.id]
# }


# # Getting alerts to my email
# resource "google_monitoring_notification_channel" "email" {
#   display_name = "Email Notification Channel"
#   type         = "email"
#   labels = {
#     email_address = var.alert_email  # Add this to your variables
#   }
# }