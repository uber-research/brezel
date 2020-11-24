# The name of the GCP project
PROJECT = "my-gcp-project"

# The Google Cloud Storage Bucket
BUCKET = "gs://my-gcp-bucket"

# The Google Cloud Registry
REGISTRY = "gcr.io/my-gcp-registry"

# This is the name of the cluster as it appears in:
#   kubectl config view --minify -o=jsonpath='{.contexts[0].context.cluster}'
CLUSTER = "gke_my-gcp-project_my-cluster-zone_my-gcp-cluster"
