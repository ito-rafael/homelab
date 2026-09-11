terraform {

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.112.0"
    }
  }

  encryption {
    key_provider "pbkdf2" "mykey" {
      passphrase = var.tofu_state_passphrase
    }
    method "aes_gcm" "mymethod" {
      keys = key_provider.pbkdf2.mykey
    }
    state {
      method = method.aes_gcm.mymethod
      enforced = true
    }
    plan {
      method = method.aes_gcm.mymethod
      enforced = true
    }
  }

}

provider "proxmox" {
  endpoint = "https://andira.lbic.fee.unicamp.br:8006/"
  # Set to true if using self-signed certificates on the Proxmox host
  insecure = true
}

variable "ssh_key_laptop" {
  type        = string
  description = "The SSH public key for the IPF laptop"
}

variable "ssh_key_desktop" {
  type        = string
  description = "The SSH public key for the Catuaba desktop"
}

variable "lxc_ip_cidr" {
  type        = string
  description = "The IP address and CIDR for the Headscale LXC"
  default     = "10.10.20.2/24"
}

variable "lxc_gateway" {
  type        = string
  description = "The default gateway for the Headscale LXC"
  default     = "10.10.20.1"
}

variable "tofu_state_passphrase" {
  type        = string
  description = "Passphrase for OpenTofu client-side state encryption"
  sensitive   = true
}

resource "proxmox_virtual_environment_container" "headscale" {
  description = "Headscale VPN Controller"
  tags        = ["core", "vpn"]
  node_name = "andira"
  vm_id     = 201

  # ensure unprivileged mode
  unprivileged = true

  # autostart
  start_on_boot = true

  # enable nesting
  features {
    nesting = true
  }

  # ensure the container starts early in the boot sequence (lower = earlier)
  startup {
    order      = 10
    up_delay   = 5
    down_delay = 5
  }

  # Using Debian 13 (Trixie) - Ensure this template is downloaded to your local storage
  operating_system {
    template_file_id = "local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
    type             = "debian"
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
    swap      = 0
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr1"
    vlan_id = 20  # "Infra" VLAN
  }

  initialization {
    hostname = "headscale"

    ip_config {
      ipv4 {
        address = var.lxc_ip_cidr
        gateway = var.lxc_gateway
      }
    }

    user_account {
      keys = [
        var.ssh_key_laptop,
        var.ssh_key_desktop
      ]
    }

}

}
