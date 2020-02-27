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

