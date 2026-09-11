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
