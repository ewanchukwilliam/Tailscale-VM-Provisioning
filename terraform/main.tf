terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73"
    }
  }
}

variable "virtual_environment_endpoint" { type = string }
variable "virtual_environment_secret" { type = string }
variable "ssh_public_key" { type = string }

provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  api_token = var.virtual_environment_secret
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}

resource "proxmox_virtual_environment_container" "nas" {
  node_name    = "CHANGE_ME" # your proxmox node name
  unprivileged = true

  initialization {
    hostname = "nas-vm"
    user_account {
      keys = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
        address = "192.168.1.56/24" # e.g. 192.168.1.55/24
        gateway = "192.168.1.254" # e.g. 192.168.1.254
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 20
  }

  cpu { cores = 2 }
  memory { dedicated = 2048 }
  features {
    nesting = true
  }

  # Bind mount host RAID share into container
  mount_point {
    path   = "/mnt/nas-share"
    volume = "/mnt/storage/nas-share"
  }
}
