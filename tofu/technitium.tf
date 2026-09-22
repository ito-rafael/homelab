locals {
  # extract the LXC template filename
  technitium_lxc_template = local.proxmox_vars.lxc_template_technitium
}

resource "proxmox_virtual_environment_container" "dns" {
  count = 2

  node_name = "andira"
  vm_id        = 203 + count.index
  # dns-1 will be vm_id 203, dns-2 will be vm_id 204

  unprivileged = true
  start_on_boot = true

  operating_system {
    template_file_id = "local:vztmpl/${local.technitium_lxc_template}"
    type             = "debian"

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
    name = "eth0"
    bridge = "vmbr2"
    vlan_id = 20  # Infra VLAN
  }

  initialization {
    hostname = "dns-${count.index + 1}"

    ip_config {
      ipv4 {
        address = "10.10.20.${count.index + 3}/24"
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
