# Define allowed external IPs for VM instances
# this constraint defines the set of Compute Engine VM instances that are allowed to use external IP addresses.
resource "google_project_organization_policy" "org_policy_vm_external_ip_access" {
  project     = var.project_id
  constraint = "compute.vmExternalIpAccess"
  list_policy {
    allow {
      all = true
    }
  }
}