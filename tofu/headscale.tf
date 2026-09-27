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
      servers = ["1.1.1.1", "1.0.0.1"]  # DNS-1, DNS-2
    }

    ip_config {
      ipv4 {
        address = "${local.ip_vars.ip_headscale_vpn}/24"
        gateway = local.ip_vars.ip_vyos_router
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
