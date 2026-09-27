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

  ssh {
    agent    = false
    username = "root"
    private_key = file("~/.ssh/id_ed25519")

    node {
      name    = "andira"
      address = "andira.lbic.fee.unicamp.br"
    }
  }
}

variable "ssh_key_laptop" {
  type        = string
  description = "The SSH public key for the IPF laptop"
}

variable "ssh_key_desktop" {
  type        = string
  description = "The SSH public key for the Catuaba desktop"
}

variable "tofu_state_passphrase" {
  type        = string
  description = "Passphrase for OpenTofu client-side state encryption"
  sensitive   = true
}

locals {
  # read the Ansible variables from the proxmox role once for all modules
  proxmox_vars = yamldecode(file("${path.module}/../ansible/roles/proxmox/vars/main.yml"))

  # read the global IP assignments from the master inventory
  ip_vars = yamldecode(file("${path.module}/../ansible/group_vars/all/ip.yml"))
}
