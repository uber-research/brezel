provider "google" {
    credentials = file("/secrets/${var.cluster}-terraform.json")
    project     = var.project
    region      = var.region
}
