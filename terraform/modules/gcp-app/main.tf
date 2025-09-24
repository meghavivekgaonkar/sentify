# -----------------------------------------------------------------------------
# 1. Google Cloud Storage (GCS) Bucket for raw data
# -----------------------------------------------------------------------------

# This bucket will be used to store uploaded customer feedback files.
resource "google_storage_bucket" "feedback_bucket" {
  name          = "sentify-feedback-${var.project_id}" # Must be globally unique
  project = var.project_id
  location      = "US-CENTRAL1"
  force_destroy = true # Allows deletion of a non-empty bucket
}
# -----------------------------------------------------------------------------
# 2. Cloud Pub/Sub Topic and Subscription
# -----------------------------------------------------------------------------

# A Pub/Sub topic to which the API service will publish new job messages.
resource "google_pubsub_topic" "feedback_topic" {
  name = "sentify-feedback-topic"
  project = var.project_id
}
# A Pub/Sub subscription for the worker service to listen for new jobs.
# This subscription will pull messages from the topic.
resource "google_pubsub_subscription" "worker_subscription" {
  name  = "sentify-worker-subscription"
  project = var.project_id
  topic = google_pubsub_topic.feedback_topic.name

  ack_deadline_seconds = 60 # Time to acknowledge messages before redelivery
  message_retention_duration = "604800s" # 7 days
}
# -----------------------------------------------------------------------------
# 3. Google Kubernetes Engine (GKE) Cluster
# -----------------------------------------------------------------------------

# Define the GKE cluster where our services will run.
# We're using a zonal cluster for simplicity and a standard node pool.
resource "google_container_cluster" "main_cluster" {
  name                     = "sentify-cluster"
  project = var.project_id
  location                 = var.region
  initial_node_count       = 1
  remove_default_node_pool = true
  
  # The GKE cluster needs to have access to other GCP services.
  # We will define a service account with the necessary permissions.
  # The cluster is configured to use this service account.

}

# Define the node pool for our cluster.
# This is where the compute instances for our containers will be created.
resource "google_container_node_pool" "primary_node_pool" {
  name       = "primary-node-pool"
  project = var.project_id
  location   = var.region
  cluster    = google_container_cluster.main_cluster.name
  node_count = 2 # Start with two nodes for high availability
  
  node_config {
    machine_type = "e2-small"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  disk_size_gb = 100
  disk_type = "pd-standard"
  }
}

# -----------------------------------------------------------------------------
# 4. Cloud SQL (PostgreSQL) Database
# -----------------------------------------------------------------------------

# Define the Cloud SQL database instance.
resource "google_sql_database_instance" "main_db_instance" {
  name             = "sentify-sql-db"
  project = var.project_id
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro" # Smallest instance for cost-effectiveness
  }
}

# Create a database inside the instance for our application.
resource "google_sql_database" "main_database" {
  project = var.project_id
  name     = "sentify-db"
  instance = google_sql_database_instance.main_db_instance.name
}
