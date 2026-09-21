variable "headscale_ip_cidr" {
  type        = string
  description = "The IP address and CIDR for the Headscale LXC"
  default     = "10.10.20.2/24"
}

locals {
  # extract the LXC template filename
  headscale_lxc_template = local.proxmox_vars.lxc_template_headscale
}

resource "proxmox_virtual_environment_container" "headscale" {
  description = "Headscale VPN Controller"
  tags        = ["core", "vpn", "headscale"]
  node_name = "andira"
  vm_id     = 202

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
    template_file_id = "local:vztmpl/${local.headscale_lxc_template}"
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
    vlan_id = 20  # Infra VLAN
  }

  initialization {
    hostname = "headscale"

    dns {
      #servers = ["10.10.20.x", "10.10.20.y"]  # DNS-1, DNS-2
      servers = ["1.1.1.1", "1.0.0.1"]  # DNS-1, DNS-2
    }

    ip_config {
      ipv4 {
        address = var.headscale_ip_cidr
        gateway = var.infra_vlan_gateway
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
