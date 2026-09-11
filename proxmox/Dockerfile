FROM debian:13-slim

ENV DEBIAN_FRONTEND=noninteractive

# install dependencies, add Proxmox keys/repos, and install the assistant
RUN apt-get update && \
    apt-get install -y wget ca-certificates && \
    wget https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg && \
    echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list && \
    apt-get update && \
    apt-get install -y proxmox-auto-install-assistant && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# map the host directory here
WORKDIR /work

# make the container act as the executable tool
ENTRYPOINT ["proxmox-auto-install-assistant"]
