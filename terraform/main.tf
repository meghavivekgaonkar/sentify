data "google_project" "project" {
  project_id = var.project_id
}
module "gcp-app" {
  source = "./modules/gcp-app"
  
  project_id = var.project_id
  region     = var.region
}