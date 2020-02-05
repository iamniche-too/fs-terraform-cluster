resource "google_compute_network" "vpc_network" {
  name = "kafka-cluster-vpc"
  auto_create_subnetworks = "false"
}

# https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "vpc_subnetwork" {
  # The name of the resource, provided by the client when initially creating
  # the resource. The name must be 1-63 characters long, and comply with
  # RFC1035. Specifically, the name must be 1-63 characters long and match the
  # regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first
  # character must be a lowercase letter, and all following characters must be
  # a dash, lowercase letter, or digit, except the last character, which
  # cannot be a dash.
  #name = "default-${var.gcp_cluster_region}"
  name = "kafka-cluster-vpc-subnet" 

  # 2^(32-20)=1024 hosts 
  ip_cidr_range = "10.0.16.0/20" 

  # The network this subnet belongs to. Only networks that are in the
  # distributed mode can have subnetworks.
  network = "kafka-cluster-vpc"

  # Configurations for secondary IP ranges for VM instances contained in this
  # subnetwork. The primary IP of each VM must belong to the primary ipCidrRange
  # of the subnetwork. The alias IPs may belong to either primary or secondary
  # ranges.
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.16.0.0/12"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.1.0.0/20" 
  }

  # When enabled, VMs in this subnetwork without external IP addresses can
  # access Google APIs and services by using Private Google Access. This is
  # set explicitly to prevent Google's default from fighting with Terraform.
  private_ip_google_access = true

  depends_on = [
    google_compute_network.vpc_network,
  ]
}

# firewall rule for services
resource "google_compute_firewall" "services" {
  name    = "kafka-cluster-vpc-allow-services"
  network = "kafka-cluster-vpc"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  target_tags   = ["kafka-cluster-node"]

  # allow from anywhere
  source_ranges = ["10.1.0.0/20"]
}

# ssh firewall rule
#resource "google_compute_firewall" "ssh" {
#  name    = "kafka-cluster-vpc-allow-ssh"
#  network = "kafka-cluster-vpc"
#
#  allow {
#    protocol = "tcp"
#    ports    = ["22"]
#  }
#
#  target_tags   = ["kafka-cluster-vpc-allow-ssh"]
#
#  # allow from anywhere
#  source_ranges = ["0.0.0.0/0"]
#}

resource "google_compute_router" "router" {
  name    = "my-router"
  network = google_compute_network.vpc_network.name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
