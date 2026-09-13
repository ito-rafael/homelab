variable "headscale_ip_cidr" {
  type        = string
  description = "The IP address and CIDR for the Headscale LXC"
  default     = "10.10.20.2/24"
}

variable "headscale_gateway" {
  type        = string
  description = "The default gateway for the Headscale LXC"
  default     = "10.10.20.1"
}

resource "proxmox_virtual_environment_container" "headscale" {
  description = "Headscale VPN Controller"
  tags        = ["core", "vpn", "headscale"]
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
    bridge = "vmbr2"
    vlan_id = 20  # "Infra" VLAN
  }

  initialization {
    hostname = "headscale"

    ip_config {
      ipv4 {
        address = var.headscale_ip_cidr
        gateway = var.headscale_gateway
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
