# Enable API's
resource "google_project_service" "enable-services" {
  for_each = toset(var.services_to_enable)

  project = var.project_id
  service = each.value
  disable_on_destroy = false
}

resource "google_pubsub_subscription" "pubsub_sub" {
 name                       = var.name
 project                    = var.project_id
 topic                      = var.topic

 depends_on = [
   google_project_service.enable-services
 ]
}