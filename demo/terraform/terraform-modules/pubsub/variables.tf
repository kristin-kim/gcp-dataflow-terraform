variable "project_id" {
  type        = string
  description = "The project in which the resource belongs. If it is not provided, the provider project is used."
}

variable "name" {
  type        = string
  description = "The name of the subscription job"
}

variable "topic" {
  type        = string
  description = "The public topic that pub/sub subscription is pulling data from"
  default     = null
}

# Service to enable
variable "services_to_enable" {
    description = "List of GCP Services to enable"
    type    = list(string)
    default =  [
        "pubsub.googleapis.com",
        # "autoscaling.googleapis.com"
    ]
  
}

# variable "temp_gcs_location" {
#   type        = string
#   description = "The public topic that pub/sub subscription is pulling data from"
#   default     = null
# }

# variable "temp_gcs_path" {
#   type        = string
#   description = "The public topic that pub/sub subscription is pulling data from"
#   default     = null
# }
