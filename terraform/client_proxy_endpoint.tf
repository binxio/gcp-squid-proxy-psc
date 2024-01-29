resource "google_compute_address" "proxy_endpoint" {
  project      = var.project_id
  region       = "europe-west1"
  name         = "squid-proxy-endpoint"
  subnetwork   = google_compute_subnetwork.source_vpc_proxy.id
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "proxy_endpoint" {
  project = var.project_id
  region  = "europe-west1"
  name    = "squid-proxy-endpoint"

  ip_address            = google_compute_address.proxy_endpoint.id
  load_balancing_scheme = "" # Prevent default to 'EXTERNAL'

  network    = google_compute_network.source_vpc.id
  subnetwork = google_compute_subnetwork.source_vpc_proxy.id

  target = google_compute_service_attachment.proxy.id
}

# Configure a friendly DNS name: proxy.xebia
resource "google_dns_record_set" "source_vpc_proxy_xebia" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.source_vpc_xebia.name
  name         = "proxy.xebia."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.proxy_endpoint.address]
}
