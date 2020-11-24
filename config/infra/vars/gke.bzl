# The list of the available nodepools as declared in:
#   //config/infra/terraform/gke_cluster.tf
NODEPOOLS = [
    "pool-general",
    "pool-experiments",
    "pool-small-experiments",
    "pool-gpu",
    "pool-gpu-highmem",
    "pool-gpu-beefy",
    "pool-compute-optimized-4",
    "pool-compute-optimized-8",
    "pool-compute-optimized-16",
    "pool-compute-optimized-60",
]

# The map of the taints associated to a given nodepool as declared in:
#   //config/infra/terraform/gke_cluster.tf
TAINTS = {
    "pool-gpu": ["special:gpu","nvidia.com/gpu:present"],
    "pool-gpu-highmem": ["special:gpu","nvidia.com/gpu:present"],
    "pool-gpu-beefy": ["special:gpu","nvidia.com/gpu:present"],
    "pool-compute-optimized-4": ["special:compute-optimized"],
    "pool-compute-optimized-8": ["special:compute-optimized"],
    "pool-compute-optimized-16": ["special:compute-optimized"],
    "pool-compute-optimized-60": ["special:compute-optimized"],
}
