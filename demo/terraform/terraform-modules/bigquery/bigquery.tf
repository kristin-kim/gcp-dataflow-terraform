# Enable API's
resource "google_project_service" "enable-services" {
  for_each = toset(var.services_to_enable)

  project = var.project_id
  service = each.value
  disable_on_destroy = false
}

#Creating bigquery dataset
resource "google_bigquery_dataset" "streaming_dataset" {
 dataset_id                 = var.dataset_id
 location                   = var.region
 project                    = var.project_id
 delete_contents_on_destroy = true
 depends_on = [
   google_project_service.enable-services
 ]
}

#Creating bigqeury table 
# terraform import google_bigquery_dataset.fraudfinder_data projects/etl-by-modules/datasets/fraudfinder_data
resource "google_bigquery_table" "streaming_table" {
 dataset_id = var.dataset_id
 table_id = var.table_id
 project    = var.project_id
 schema     = var.schema
 deletion_protection=false
 depends_on = [
   google_bigquery_dataset.streaming_dataset,
   google_project_service.enable-services
 ]
}
