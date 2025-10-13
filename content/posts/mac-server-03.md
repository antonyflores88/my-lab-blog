---
title: "From Old Mac to DevOps Lab – Part 4: Docker + Terraform = My Own Mini Cloud"
description: "Running Docker containers remotely from WSL using Terraform over SSH. The final piece that turns an old MacBook into a real DevOps lab."
date: 2025-10-10
tags: [Ubuntu Server, Docker, Terraform, DevOps Lab, Infrastructure as Code]
---

# From Old Mac to DevOps Lab – Part 4: Docker + Terraform = My Own Mini Cloud

This is where it all comes together.  
After setting up Ubuntu Server, Wi-Fi, and SSH, I wanted to treat my old MacBook like a **real cloud instance** — something I could deploy to using code, not clicks.  
That’s where **Docker** and **Terraform** come in.  

Terraform runs from my **Windows WSL**, connects to the **Mac over SSH**, and tells Docker what to do — basically my own little cloud at home.

---

## Step 1 – Install Docker on the Mac

```bash
# Install Docker & Compose
sudo apt install docker.io docker-compose -y

# Add your user to the Docker group so sudo isn't required
sudo usermod -aG docker $USER

# Enable Docker on startup and start it now
sudo systemctl enable --now docker

# Reboot to apply group changes
sudo reboot

# After reboot, confirm Docker works without sudo
docker ps
```
---

## Step 2 – Install Terraform on WSL

```bash
# Update packages and install helpers
sudo apt update
sudo apt install wget unzip -y

# Download Terraform binary
wget https://releases.hashicorp.com/terraform/1.9.6/terraform_1.9.6_linux_amd64.zip

# Unzip and move it to /usr/local/bin
unzip terraform_1.9.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Confirm version
terraform -version
```

---

## Step 3 – Create the Terraform Project
```bash
# Create working folder
mkdir macserver-terraform && cd macserver-terraform

# --- provider.tf ---
# Configure the Docker provider to talk over SSH to the Mac
cat <<'EOF' > provider.tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {
  host = "ssh://tony@192.168.1.16"
}
EOF

# --- main.tf ---
# Define an nginx container with exposed port 8080
cat <<'EOF' > main.tf
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  name  = "mynginx"
  image = docker_image.nginx.name
  ports {
    internal = 80
    external = 8080
  }
}
EOF
```

---

## Step 4 – Deploy the Container
```bash
# Initialize Terraform
terraform init

# Preview the plan
terraform plan

# Apply changes (create the container)
terraform apply

# Open browser at http://192.168.1.16:8080
# → you should see the nginx welcome page
```
---

## Step 5 – Test Destroy & Rebuild
```bash
# Remove everything
terraform destroy

# Redeploy instantly
terraform apply
```
It’s exactly how DevOps engineers work in the cloud — plan, apply, destroy, repeat.

---

## Step 6 – What’s Happening Behind the Scenes

- **WSL = your control plane (like an Azure DevOps agent)**
- **SSH = secure channel to your Mac**
- **Terraform = the brain; compares desired vs. actual state**
- **Docker = the runtime executing containers on your Mac**

Together they form a small-scale version of a cloud environment — except it’s sitting on your desk.

---

## Step 7 – Optional: Lock It Down

```bash
# Disable password SSH logins
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Enable UFW firewall and allow only your workstation
sudo apt install ufw fail2ban -y
sudo ufw allow from 192.168.1.20 to any port 22 proto tcp
sudo ufw enable
```

---

## Recap of the Series

Your DevOps lab is now complete:

- **Ubuntu Server**
- **Wi-Fi + Static IP**
- **SSH Access + Battery Alias**
- **Docker + Terraform Remote Deployments**

You’ve basically recreated the workflow of a cloud environment —
only this one runs on recycled hardware, fully under your control.

---

## What’s Next?

I might add Redis, Grafana, and maybe a small Flask API next, just to see how far this setup can go.
But for now, this old Mac is officially a DevOps playground — and it doesn’t even get warm anymore.

✦ Tony
CloudPilot 365 | Because the cloud starts at home.