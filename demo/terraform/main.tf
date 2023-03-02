# ----------------------------------------------------------------------------------------------------------------------
# Main modules
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# Configure VPC
# ----------------------------------------------------------------------------------------------------------------------
module "demo-vpc" {
  source                     = "./terraform-modules/vpc"
  project_id = var.project_id
  project_number = var.project_number
} 

# -------------------------------------------------------------------------------------------------------------------
# Running Batch ETL
# ----------------------------------------------------------------------------------------------------------------------
# 1) Setting up batch process bucket and data 
module "dataflow-bucket" {
  source  = "./terraform-modules/gcs"
  bucket_name          = "${var.project_id}-${var.batch_bucket_name}"
  region        = var.region
  project_id = var.project_id
  depends_on = [
    module.demo-vpc
  ]
}

# 2) Running Batch Dataflow job
module "batch-dataflow-job" { 
  source                = "./terraform-modules/dataflow_job"
  project_id            = var.project_id
  name                  = "wordcount-terraform-example"
  template_gcs_path     = "gs://dataflow-templates/latest/Word_Count"
  temp_gcs_location     = module.dataflow-bucket.bucket-name

  parameters = {
    inputFile = "gs://dataflow-samples/shakespeare/kinglear.txt"
    output    = "gs://${module.dataflow-bucket.bucket-name}/output/my_output"
  }
  depends_on = [
    module.demo-vpc,
    module.dataflow-bucket
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Running Streaming ETL
# ----------------------------------------------------------------------------------------------------------------------

# 1) Creating pubsub subscription receiving streaming data from public topic
module "pubsub_subscription" {
  source                     = "./terraform-modules/pubsub"
  name                       = "streaming_data"  
  project_id                    = var.project_id
  topic                      = var.topic
  depends_on = [module.demo-vpc.default] 
}

# 2) Setting up the temp stroage bucket for streaming
module "streaming_temp-bucket" {
 source  = "./terraform-modules/gcs"
 force_destroy               = true
  bucket_name          = "${var.project_id}-streaming_temp"
  region        = var.region
  project_id = var.project_id
  
  depends_on = [module.pubsub_subscription]
}

# 3) Creating BQ dataset and table for streaming dataflow job
module "bigquery" {
  # For dataset
  source  = "./terraform-modules/bigquery"
  region        = var.region
  project_id                    = var.project_id
  dataset_id                 = "fraudfinder_data"

  # For table 
  table_id   = "streaming_data_ready"
  schema = "[{\"name\":\"TX_ID\",\"type\":\"STRING\"},{\"name\":\"TX_TS\",\"type\":\"TIMESTAMP\"},{\"name\":\"CUSTOMER_ID\",\"type\":\"STRING\"},{\"name\":\"TERMINAL_ID\",\"type\":\"STRING\"},{\"name\":\"TX_AMOUNT\",\"type\":\"NUMERIC\"}]"
}

# 2) Running Batch Dataflow job
module "stream-dataflow-job" {
  source                = "./terraform-modules/dataflow_job"
  project_id            = var.project_id
  name                  = "df-pubsub-biquery1"
  template_gcs_path     = "gs://dataflow-templates/2022-01-24-00_RC00/PubSub_Subscription_to_BigQuery"
  temp_gcs_location     = module.dataflow-bucket.bucket-name
  parameters = {
    inputSubscription= module.pubsub_subscription.sub-id
    outputTableSpec= "${var.project_id}:${module.bigquery.dataset-id}.${module.bigquery.table-id}"
  }
  # serverless option
   additional_experiments = ["enable_prime"]
   depends_on = [module.bigquery,
   module.pubsub_subscription,
   module.streaming_temp-bucket]
}
