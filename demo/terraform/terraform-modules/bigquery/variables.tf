variable "project_id" {
  type        = string
  description = "The project in which the resource belongs. If it is not provided, the provider project is used."
}

# Service to enable
variable "services_to_enable" {
    description = "List of GCP Services to enable"
    type    = list(string)
    default =  [
        "bigquery.googleapis.com",
        "bigquerystorage.googleapis.com",
    ]
  
}

variable "region" {
  type        = string
  description = "The region in which the created job should run. Also determines the location of the staging bucket if created."
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "The zone in which the created job should run."
  default     = "us-central1-a"
}


variable "schema" {
  type        = string
  description = "The bigquery table schema"
  default     = null
}

variable "table_id" {
  type        = string
  description = "The name for the Bigquery table id"
  default     = null
}

variable "dataset_id" {
  type        = string
  description = "The name for the Bigquery dataset"
  default     = null
}