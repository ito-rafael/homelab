# Makefile for OpenTofu Operations

SHELL := /bin/bash
# Phony targets ensure make doesn't look for files named 'plan' or 'apply'
.PHONY: init plan apply destroy

# The core command wrapper
# The '@' prefix prevents the command string itself from being echoed to the terminal.
# The '$$' is required in Makefiles to escape the '$' so it passes properly to the bash shell.
define TOFU_ENV
	@set -a; source ../proxmox/.env; set +a; \
	export TF_VAR_tofu_state_passphrase=$$(pass lbic/tofu-state); \
	export PROXMOX_VE_API_TOKEN=$$(pass lbic/proxmox-api-token); \
	export TF_VAR_ssh_key_laptop=$$SSH_KEY_LAPTOP; \
	export TF_VAR_ssh_key_desktop=$$SSH_KEY_DESKTOP; \
	tofu
endef

init:
	$(TOFU_ENV) init $(TOFU_ARGS)

plan:
	$(TOFU_ENV) plan $(TOFU_ARGS)

apply:
	$(TOFU_ENV) apply $(TOFU_ARGS)

destroy:
	$(TOFU_ENV) destroy
