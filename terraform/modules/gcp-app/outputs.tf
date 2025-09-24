# This file defines the output values for the 'gcp-app' module.
# These values can be referenced by the root module or other modules.

# The name of the Google Cloud Storage bucket.
output "gcs_bucket_name" {
  description = "The unique name of the feedback GCS bucket."
  value       = google_storage_bucket.feedback_bucket.name
}

# The name of the Cloud Pub/Sub topic.
output "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic for feedback jobs."
  value       = google_pubsub_topic.feedback_topic.name
}

# The name of the Cloud Pub/Sub subscription.
output "pubsub_subscription_name" {
  description = "The name of the Pub/Sub subscription for the worker service."
  value       = google_pubsub_subscription.worker_subscription.name
}

# The name of the GKE cluster.
output "gke_cluster_name" {
  description = "The name of the Google Kubernetes Engine cluster."
  value       = google_container_cluster.main_cluster.name
}

# The name of the Cloud SQL instance.
output "sql_instance_name" {
  description = "The name of the Cloud SQL database instance."
  value       = google_sql_database_instance.main_db_instance.name
}