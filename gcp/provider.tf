provider "google" {
  credentials = file("terraform-test-262517-e35fa404a379.json")
  project = "terraform-test-262517"
  region  = "europe-west2"
  zone    = "europe-west2-a"
}
