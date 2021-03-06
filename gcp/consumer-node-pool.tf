# https://www.terraform.io/docs/providers/google/r/container_node_pool.html
resource "google_container_node_pool" "consumer_node_pool" {
  # The location (region or zone) in which the cluster resides
  location = google_container_cluster.cluster.location

  count = 3 

  # The name of the node pool. Instance groups created will have the cluster
  # name prefixed automatically.
  name = "consumer-node-pool" 

  # The cluster to create the node pool for.
  cluster = google_container_cluster.cluster.name

  initial_node_count = 3

  # Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage.
  autoscaling {
    # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
    min_node_count = 3 

    # Maximum number of nodes in the NodePool. Must be >= min_node_count.
    max_node_count = 3 
  }

  # Node management configuration, wherein auto-repair and auto-upgrade is configured.
  management {
    # Whether the nodes will be automatically repaired.
    auto_repair = true 

    # Whether the nodes will be automatically upgraded.
    auto_upgrade = true
  }

  # Parameters used in creating the cluster's nodes.
  node_config {
    # Machine type comes with 10Gbps
    machine_type = "n1-standard-2" 

    service_account = google_service_account.default.email 

    # Size of the disk attached to each node, specified in GB. The smallest
    # allowed disk size is 10GB. Defaults to 100GB.
    disk_size_gb = 10

    # Type of the disk attached to each node (e.g. 'pd-standard' or 'pd-ssd').
    # If unspecified, the default disk type is 'pd-standard'
    disk_type = "pd-standard"

    # A boolean that represents whether or not the underlying node VMs are
    # preemptible. See the official documentation for more information.
    # Defaults to false.
    preemptible = false 

    # The set of Google API scopes to be made available on all of the node VMs
    # under the "default" service account. These can be either FQDNs, or scope
    # aliases. The cloud-platform access scope authorizes access to all Cloud
    # Platform services, and then limit the access by granting IAM roles
    # https://cloud.google.com/compute/docs/access/service-accounts#service_account_permissions
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # The metadata key/value pairs assigned to instances in the cluster.
    metadata = {
      # https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata
      disable-legacy-endpoints = "true"
    }

    labels = {
      consumer-node = "true"
    }

    tags = [ 
      "consumer-node" 
    ]
  }

  # Change how long update operations on the node pool are allowed to take
  # before being considered to have failed. The default is 10 mins.
  # https://www.terraform.io/docs/configuration/resources.html#operation-timeouts
  timeouts {
    update = "20m"
  }
}

