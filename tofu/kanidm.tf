variable "kanidm_ip_cidr" {
  type        = string
  description = "The IP address and CIDR for the Kanidm LXC"
  default     = "10.10.20.5/24"
}

locals {
  # extract the LXC template filename
  kanidm_lxc_template = local.proxmox_vars.lxc_template_kanidm
}

resource "proxmox_virtual_environment_container" "kanidm" {
  description = "Kanidm IAM Server"
  tags        = ["core", "iam", "kanidm"]
  node_name   = "andira"
  vm_id       = 205

  # ensure unprivileged mode
  unprivileged = true

  # autostart
  start_on_boot = true

  # enable nesting (recommended for systemd/auth daemons)
  features {
    nesting = true
  }

  # ensure the container starts after the network and DNS
  startup {
    order      = 15
    up_delay   = 5
    down_delay = 5
  }

  operating_system {
    template_file_id = "local:vztmpl/${local.kanidm_lxc_template}"
    type             = "debian"
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
    swap      = 256
  }

  disk {
    datastore_id = "local-lvm"
    size         = 10
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr2"
    vlan_id = 20  # Infra VLAN
  }

  initialization {
    hostname = "kanidm"

    dns {
      # use internal DNS so Kanidm can resolve infrastructure names if needed
      servers = var.infra_dns_servers
    }

    ip_config {
      ipv4 {
        address = var.kanidm_ip_cidr
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
