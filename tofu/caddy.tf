locals {
  # extract the LXC template filename
  caddy_lxc_template = local.proxmox_vars.lxc_template_caddy
}

resource "proxmox_virtual_environment_container" "caddy" {
  description = "Caddy Reverse Proxy & Let's Encrypt TLS"
  tags        = ["network", "proxy", "caddy"]
  node_name   = "andira"
  vm_id       = 206

  # ensure unprivileged mode
  unprivileged = true

  # autostart
  start_on_boot = true

  # ensure the container starts after DNS but before IAM/VPN
  startup {
    order      = 12
    up_delay   = 5
    down_delay = 5
  }

  operating_system {
    template_file_id = "local:vztmpl/${local.caddy_lxc_template}"
    type             = "debian"
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr2"
    vlan_id = 20  # Infra VLAN
  }

  initialization {
    hostname = "caddy"

    dns {
      servers = [local.ip_vars.ip_technitium_dns1, local.ip_vars.ip_technitium_dns2]
    }

    ip_config {
      ipv4 {
        address = "${local.ip_vars.ip_caddy_reverseproxy}/24"
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
