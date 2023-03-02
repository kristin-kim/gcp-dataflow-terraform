
output "dataset-id" {
  value = google_bigquery_dataset.streaming_dataset.dataset_id
}
output "table-id" {
  value = google_bigquery_table.streaming_table.table_id
}
