variable "vyos_ip_cidr" {
  type        = string
  description = "The management IP address and CIDR for the VyOS router"
  default     = "10.10.10.1/24"
}

variable "vyos_gateway" {
  type        = string
  description = "The default gateway for the VyOS router (usually the university network gateway)"
  default     = "10.10.10.254"
}

resource "proxmox_virtual_environment_vm" "vyos" {
  name        = "vyos"
  description = "VyOS Core Router"
  node_name   = "andira"
  vm_id       = 201
  tags        = ["core", "router", "vyos"]

  # router must boot before LXCs and Kubernetes
  started = true
  on_boot = true
  startup {
    order      = 1
    up_delay   = 10
  }

  # communicates with the injected qemu-guest-agent
  agent {
    enabled = true
  }

  # eth0: WAN Interface
  # Transit Network (facing the physical network)
  network_device {
    bridge = "vmbr1"
  }

  # eth1: LAN Interface
  # Internal Trunk (VLAN Trunk for internal lab networks)
  network_device {
    bridge = "vmbr2"
  }

  disk {
    datastore_id = "local-lvm"
    # ensure the VyOS image has Cloud-Init QCOW2 support
    file_id      = "local:iso/vyos-1.4-cloud-init.qcow2"
    interface    = "virtio0"
    size         = 10
  }

  # Cloud-Init Bootstrap
  initialization {

    user_account {
      username = "vyos"
      keys     = [
        var.ssh_key_laptop,
        var.ssh_key_desktop
      ]
    }

    ip_config {
      ipv4 {
        address = var.vyos_ip_cidr
        gateway = var.vyos_gateway
      }
    }

}

}
