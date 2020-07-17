# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "cluster" {

  # If you specify a zone (such as us-central1-a), the cluster will be a zonal 
  # cluster with a single cluster master. If you specify a region (such as us-west1),
  # the cluster will be a regional cluster with multiple masters spread across zones in the region
  location = "europe-west2-a"

  name = "gke-kafka-cluster" 

  # The minimum version of the master. GKE will auto-update the master to new
  # versions, so this does not guarantee the current master version--use the
  # read-only master_version field to obtain that. If unset, the cluster's
  # version will be set by GKE to the version of the most recent official release
  # (which is not necessarily the latest version). Most users will find the
  # google_container_engine_versions data source useful - it indicates which
  # versions are available. If you intend to specify versions manually, the
  # docs describe the various acceptable formats for this field.
  min_master_version = "latest"

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00" 
    }
  }

  # A set of options for creating a private cluster.
  private_cluster_config {
    # Whether the master's internal IP address is used as the cluster endpoint.
    enable_private_endpoint = false

    # Whether nodes have internal IP addresses only. If enabled, all nodes are
    # given only RFC 1918 private addresses and communicate with the master via
    # private networking.
    enable_private_nodes = true

    master_ipv4_cidr_block = "172.16.0.0/28" 
  }

  # Configuration options for the NetworkPolicy feature.
  network_policy {
    # Whether network policy is enabled on the cluster. Defaults to false.
    # In GKE this also enables the ip masquerade agent
    # https://cloud.google.com/kubernetes-engine/docs/how-to/ip-masquerade-agent
    enabled = true 

    # The selected network policy provider. Defaults to PROVIDER_UNSPECIFIED.
    provider = "CALICO"
  }

  master_auth {
    # Setting an empty username and password explicitly disables basic auth
    username = ""
    password = ""

    # Whether client certificate authorization is enabled for this cluster.
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # The configuration for addons supported by GKE.
  addons_config {
    # The status of the Kubernetes Dashboard add-on, which controls whether
    # the Kubernetes Dashboard is enabled for this cluster. It is enabled by default.
    #kubernetes_dashboard {
    #  disabled = true
    #}

    http_load_balancing {
      disabled = "false" 
    }

    # Whether we should enable the network policy addon for the master. This must be
    # enabled in order to enable network policy for the nodes. It can only be disabled
    # if the nodes already do not have network policies enabled. Defaults to disabled;
    # set disabled = false to enable.
    network_policy_config {
      disabled = false
    }
  }

  network    = "kafka-cluster-vpc" 
  subnetwork = "kafka-cluster-vpc-subnet" 

  # Configuration for cluster IP allocation. As of now, only pre-allocated
  # subnetworks (custom type with secondary ranges) are supported. This will
  # activate IP aliases.
  ip_allocation_policy {
    # Whether alias IPs will be used for pod IPs in the cluster. Defaults to
    # true if the ip_allocation_policy block is defined, and to the API
    # default otherwise. Prior to June 17th 2019, the default on the API is
    # false; afterwards, it's true.
    #use_ip_aliases = true

    cluster_secondary_range_name  = "pods" 
    services_secondary_range_name = "services" 
  }

  # It's not possible to create a cluster with no node pool defined, but we
  # want to only use separately managed node pools. So we create the smallest
  # possible default node pool and immediately delete it.
  remove_default_node_pool = true

  # The number of nodes to create in this cluster (not including the Kubernetes master).
  initial_node_count = 10 

  # The desired configuration options for master authorized networks. Omit the
  # nested cidr_blocks attribute to disallow external access (except the
  # cluster node IPs, which GKE automatically whitelists).
  # Caution: Using (0.0.0.0/0) will allow the public Internet to reach your cluster master endpoint through HTTPS.
  master_authorized_networks_config {
    cidr_blocks { 
      cidr_block = "0.0.0.0/0"
      display_name = "default" 
    } 
  }
 
  # Change how long update operations on the cluster are allowed to take
  # before being considered to have failed. The default is 10 mins.
  # https://www.terraform.io/docs/configuration/resources.html#operation-timeouts
  timeouts {
    update = "20m"
  }

  depends_on = [
    google_compute_subnetwork.vpc_subnetwork,google_service_account.default,
  ]
}

