terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("credentials.json")
  project = "tcc2-366316"
  region  = "southamerica-east1"
  zone    = "southamerica-east1-a"
}