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

locals {
  # read the Ansible variables
  vyos_vars = yamldecode(file("${path.module}/../ansible/roles/vyos/vars/main.yml"))

  # replace the architecture tag
  path_step1 = replace(local.vyos_vars.vyos_target_image, "{{ vyos_architecture }}", local.vyos_vars.vyos_architecture)
  # replace the version tag
  path_step2 = replace(local.path_step1, "{{ vyos_build_version }}", local.vyos_vars.vyos_build_version)
  # extract the final filename
  vyos_image_name = basename(local.path_step2)

  vyos_eth0_mac = local.vyos_vars.vyos_eth0_mac
  vyos_eth1_mac = local.vyos_vars.vyos_eth1_mac

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
    mac_address = local.vyos_eth0_mac
  }

  # eth1: LAN Interface
  # Internal Trunk (VLAN Trunk for internal lab networks)
  network_device {
    bridge = "vmbr2"
    mac_address = local.vyos_eth1_mac
  }

  disk {
    datastore_id = "local-lvm"
    # ensure the VyOS image has QCOW2 support
    file_id      = "local:iso/${local.vyos_image_name}"
    interface    = "virtio0"
    file_format  = "raw"
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
