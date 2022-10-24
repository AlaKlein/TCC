resource "google_compute_firewall" "default" { #Create a firewall
    name    = "web-firewall"
    network = "default"

  allow { #Allow access to ports TCP 22(SSH) and 8080(Tomcat) 
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = ["0.0.0.0/0"] #Specify allowed addresses
  target_tags = ["vm"] #Specify VM
  }

  resource "tls_private_key" "ssh" { #Create SSH Key
  algorithm = "RSA"
  rsa_bits  = 4096
}

  resource "local_file" "ssh_private_key_pem" { #Save key to project directory
  content         = tls_private_key.ssh.private_key_pem
  filename        = "id_rsa"
  file_permission = "0400"
}

resource "google_compute_instance" "GCP-VM" { #Create VM
  name         = "terraform-centos"
  machine_type = "t2d-standard-2"
  zone         = "southamerica-east1-a"
  tags = ["vm"]

  boot_disk {
    initialize_params { #Choose OS image
      image = "centos-cloud/centos-7"
    }
  }

  network_interface { #GCP can use a default network setting
    network = "default"

    access_config { #Create public IP
    }
  }

  metadata = { #Add ssh key to VM
    ssh-keys = "ala_klein:${tls_private_key.ssh.public_key_openssh}"
  }

  provisioner "local-exec" { #Provision application with Ansible
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ala_klein -i '${google_compute_instance.GCP-VM.network_interface.0.access_config.0.nat_ip} ,' --private-key ./id_rsa /mnt/c/Users/Klein/Desktop/TCC/Ansible.yml" 
  }
}