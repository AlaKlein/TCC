resource "google_compute_firewall" "firewall" { #Create a firewall
    name    = var.firewall_name
    network = var.network_name

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
  filename        = var.cert_name
  file_permission = "0400"
}

resource "google_compute_instance" "GCP-VM" { #Create VM
  name         = var.vm_name
  machine_type = var.machine_type 
  zone         = var.zone
  tags = ["vm"]

  boot_disk {
    initialize_params { #Choose OS image
      image = var.vm_image
    }
  }

  network_interface { #GCP can use a default network setting
    network = var.network_name

    access_config { #Create public IP
    }
  }

  metadata = { #Add ssh key to VM
    ssh-keys = "ala_klein:${tls_private_key.ssh.public_key_openssh}"
  }

  provisioner "local-exec" { #Prepare file "Redeploy" to receive VM IP
    command = "./dynamicRedeploy.sh"
  }

  provisioner "local-exec" { #Save VM IP to "Redepoy" file
    command = "sed -i 's/{host}/${google_compute_instance.GCP-VM.network_interface.0.access_config.0.nat_ip}/g' ./Redeploy"
  }

  provisioner "local-exec" { #Provision application with Ansible
    command = "sleep 10; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ala_klein -i '${google_compute_instance.GCP-VM.network_interface.0.access_config.0.nat_ip} ,' --private-key ./id_rsa /mnt/c/Users/Klein/Desktop/TCC/Ansible.yml"
  }

}