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

variable "infra_vlan_gateway" {
  type        = string
  description = "The default gateway for the Infra VLAN 20"
  default     = "10.10.20.1"  # VyOS Router IP in this network
}

variable "infra_dns_servers" {
  type        = list(string)
  description = "The internal Technitium DNS servers for the Infra VLAN"
  default     = ["10.10.20.3", "10.10.20.4"]
}

locals {
  # read the Ansible variables from the proxmox role once for all modules
  proxmox_vars = yamldecode(file("${path.module}/../ansible/roles/proxmox/vars/main.yml"))
}
