#!/usr/bin/env bash

# load variables safely
set -a
source .env
set +a

# extract just the variable names from the .env file to create an allow-list
# this creates a string like: $ADMIN_EMAIL,$PROXMOX_PASSWORD_HASH,$SERVER_IP_CIDR
ALLOW_LIST=$(awk -F= '{print "$"$1}' .env | paste -sd, -)

# run envsubst restricted to only the variables in the allow-list
envsubst "$ALLOW_LIST" < answer_lbic.tmpl.toml > answer_lbic.toml

echo "Success: answer_lbic.toml generated securely."
