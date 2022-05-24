module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  version = "17.3.0"
  kubernetes_version = "1.22"

  name       = var.environment
  project_id = data.google_client_config.default.project
  region     = data.google_client_config.default.region
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets_names[0]
  zones      = ["europe-west3-a"]

  ip_range_pods     = module.vpc.subnets_secondary_ranges[0][0].range_name
  ip_range_services = module.vpc.subnets_secondary_ranges[0][1].range_name

  horizontal_pod_autoscaling = true
  grant_registry_access      = true
  remove_default_node_pool   = true
  regional                   = false

  node_pools = [
    {
      name               = "standard-node-pool"
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 6
      disk_size_gb       = 40
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    standard-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    standard-node-pool = {
      standard-node-pool = true
    }
  }

  node_pools_metadata = {
    all                = {}
    standard-node-pool = {}
  }

  node_pools_taints = {
    all = []

    standard-node-pool = [
      {
        key    = "standard-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    standard-node-pool = [
      "standard-node-pool",
    ]
  }
}

module "gke_auth" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version = "17.3.0"

  cluster_name = var.environment
  location     = module.gke.location
  project_id   = data.google_client_config.default.project
}
