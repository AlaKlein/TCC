resource "google_compute_firewall" "default" {
    name    = "web-firewall"
    network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["vm"]
  }

  resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

  resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "id_rsa"
  file_permission = "0400"
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

  metadata = { #Add ssh key to VM
    ssh-keys = "ala_klein:${tls_private_key.ssh.public_key_openssh}"
  }

  provisioner "local-exec" { #Provision application with Ansible
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ala_klein -i '${google_compute_instance.GCP-VM.network_interface.0.access_config.0.nat_ip} ,' --private-key ./id_rsa /mnt/c/Users/Klein/Desktop/TCC/Ansible.yml" 
  }
}