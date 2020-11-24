data "google_container_engine_versions" "gcp_zone" {
    provider       = google
    location       = var.zone
}


resource "google_container_cluster" "primary" {
    name     = var.cluster
    location = var.zone

    min_master_version       = data.google_container_engine_versions.gcp_zone.latest_master_version
    remove_default_node_pool = true
    initial_node_count       = 1
    resource_usage_export_config {
        enable_network_egress_metering = false
        enable_resource_consumption_metering = true

        bigquery_destination {
            dataset_id = "gke_cluster_mon"
        }
    }
}


resource "google_container_node_pool" "general" {
    name       = "pool-general"
    location   = var.zone
    cluster    = google_container_cluster.primary.name
    version    = google_container_cluster.primary.min_master_version

    initial_node_count = 1

    autoscaling {
        min_node_count = 0
        max_node_count = 3
    }

    node_config {
        machine_type = "e2-standard-2"
        disk_size_gb = 30
        image_type   = "COS"

        metadata = {
            disable-legacy-endpoints = "true"
        }

        oauth_scopes = [
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]
    }
}

resource "google_container_node_pool" "small_single_cpu_nodes" {
    name       = "pool-small-experiments"
    location   = var.zone
    cluster    = google_container_cluster.primary.name
    version    = google_container_cluster.primary.min_master_version

    initial_node_count = 1

    autoscaling {
        min_node_count = 0
        max_node_count = 20
    }

    node_config {
        machine_type = "n1-standard-1"
        disk_size_gb = 30
        image_type   = "COS"

        metadata = {
            disable-legacy-endpoints = "true"
        }

        oauth_scopes = [
            "https://www.googleapis.com/auth/devstorage.read_write",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]
    }
}

resource "google_container_node_pool" "double_cpu_nodes" {
    name       = "pool-experiments"
    location   = var.zone
    cluster    = google_container_cluster.primary.name
    version    = google_container_cluster.primary.min_master_version

    initial_node_count = 0

    autoscaling {
        min_node_count = 0
        max_node_count = 50
    }

    node_config {
        machine_type = "n2-highmem-2"
        disk_size_gb = 30
        image_type   = "COS"

        metadata = {
            disable-legacy-endpoints = "true"
        }

        oauth_scopes = [
            "https://www.googleapis.com/auth/devstorage.read_write",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]
    }
}

resource "google_container_node_pool" "compute_optimized_nodes" {
    for_each = {
        4  = [8]
        8  = [3]
        16 = [3]
        60 = [1]
    }
    name       = "pool-compute-optimized-${each.key}"
    location   = var.zone
    cluster    = google_container_cluster.primary.name
    version    = google_container_cluster.primary.min_master_version

    initial_node_count = 1

    autoscaling {
        min_node_count = 0
        max_node_count = each.value[0]
    }

    node_config {
        machine_type = "c2-standard-${each.key}"
        disk_size_gb = 15
        image_type   = "COS"

        metadata = {
            disable-legacy-endpoints = "true"
        }

        oauth_scopes = [
            "https://www.googleapis.com/auth/devstorage.read_write",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]

        taint {
            key    = "special"
            value  = "compute-optimized"
            effect = "NO_SCHEDULE"
        }
    }
}

resource "google_container_node_pool" "gpu" {
    for_each = {
        "standard"  = ["pool-gpu", "n1-standard-4", "nvidia-tesla-t4", 1]
        "highmem"   = ["pool-gpu-highmem", "n1-highmem-4","nvidia-tesla-t4", 1]
        "beefy"     = ["pool-gpu-beefy", "n1-highmem-16","nvidia-tesla-v100", 8]
    }
    name       = each.value[0]
    location   = var.zone
    cluster    = google_container_cluster.primary.name
    version    = google_container_cluster.primary.min_master_version

    initial_node_count = 0

    autoscaling {
        min_node_count = 0
        max_node_count = 24
    }

    node_config {
        machine_type = each.value[1]
        disk_size_gb = 50
        image_type   = "COS"

        metadata = {
            disable-legacy-endpoints = "true"
        }

        oauth_scopes = [
            "https://www.googleapis.com/auth/devstorage.read_write",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]

        guest_accelerator {
            type  = each.value[2]
            count = each.value[3]
        }

        taint {
            key    = "special"
            value  = "gpu"
            effect = "NO_SCHEDULE"
        }

        taint {
            key    = "nvidia.com/gpu"
            value  = "present"
            effect = "NO_SCHEDULE"
        }
    }

    provisioner "local-exec" {
        command = "kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml"
    }
}
