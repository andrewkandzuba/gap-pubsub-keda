terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.13.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.13.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  impersonate_service_account = var.service_account_email
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  impersonate_service_account = var.service_account_email
}

data "google_client_config" "default" {}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "dt-sandbox-vpc"
  auto_create_subnetworks = false
}

# Two private subnets
resource "google_compute_subnetwork" "private_subnet_1" {
  name          = "dt-sandbox-subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
  private_ip_google_access = true
}

# Cloud NAT for outbound internet access
resource "google_compute_router" "router" {
  name    = "dt-sandbox-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "dt-sandbox-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.private_subnet_1.id

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  node_config {
    service_account = var.service_account_email
  }

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "dt-sandbox-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    service_account = var.service_account_email
  }
}

# Enable Pub/Sub API
resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

# Create a Pub/Sub topic
resource "google_pubsub_topic" "dt_message" {
  name                       = "dt-message"
  project                    = var.project_id
  message_retention_duration = "600s"
  depends_on = [google_project_service.pubsub]
}

# Create a Pub/Sub subscription to the dt-message topic
resource "google_pubsub_subscription" "dt_message_subscription" {
  name  = "dt-message-subscription"
  topic = google_pubsub_topic.dt_message.name
  project = var.project_id

  # Retain messages for 10 minutes
  message_retention_duration = "600s"
  # Set the acknowledgment deadline to 20 seconds
  ack_deadline_seconds = 20

  # Enable message ordering if needed
  # enable_message_ordering = false

  # Set a retry policy
  retry_policy {
    minimum_backoff = "10s"
  }

  depends_on = [google_pubsub_topic.dt_message]
}
