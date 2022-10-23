
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

resource "google_compute_firewall" "default" {
    name    = "web-firewall"
    network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["vm"]
  }

resource "google_compute_instance" "GCP-VM" {
  name         = "terraform-centos"
  machine_type = "t2d-standard-2"
  zone         = "southamerica-east1-a"
  tags = ["vm"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  #Add ssh key to VM
  metadata = {
    ssh-keys = "ala_klein:${file(var.ssh_public_key_filepath)}"
  }

  provisioner "local-exec" {
    command = "./dynamicinventory.sh"
  }

  #Copy VM IP Address to local file, so Ansible can use it to access the VM
  provisioner "local-exec" {
    command = "sed -i 's/{host}/${google_compute_instance.GCP-VM.network_interface.0.access_config.0.nat_ip}/g' ./inventory"
  }

  #Run Ansible Playbook
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook /mnt/c/Users/Klein/Desktop/TCC/Ansible.yml -i ./inventory"
  }
}