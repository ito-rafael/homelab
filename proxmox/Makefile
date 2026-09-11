# Makefile for Proxmox Bare-Metal Bootstrapping

SHELL := /bin/bash
.PHONY: clean

# make the TOML file depend on the template and the .env file.
# it will only rebuild if those files change.
answer_lbic.toml: answer_lbic.tmpl.toml .env
	@echo "Generating answer_lbic.toml securely..."
	@set -a; source .env; set +a; \
	ALLOW_LIST=$$(awk -F= '{print "$$"$$1}' .env | paste -sd, -); \
	envsubst "$$ALLOW_LIST" < answer_lbic.tmpl.toml > answer_lbic.toml
	@echo "Success: answer_lbic.toml generated."

clean:
	rm -f answer_lbic.toml
