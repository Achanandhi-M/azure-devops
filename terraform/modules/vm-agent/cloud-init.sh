#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive

echo "=== Cloud-init: Starting agent provisioning ==="

# 1. Update and install basic tools
apt-get update -y
apt-get upgrade -y
apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg jq unzip wget default-jre default-jdk gcc g++ make software-properties-common

# 2. Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# 3. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker azureuser

# 4. Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 5. Install .NET 8 SDK
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update
apt-get install -y dotnet-sdk-8.0

# 6. Install Azure DevOps Agent (4.x — required for Azure DevOps Services)
echo "=== Fetching agent download URL from Azure DevOps API ==="
mkdir -p /opt/azdo/agent
cd /opt/azdo/agent

# Use the Azure DevOps REST API to get the latest agent package URL
AGENT_URL=$(curl -s -u "user:${AZDO_PAT}" \
  "${AZDO_URL}/_apis/distributedtask/packages/agent?platform=linux-x64&\$top=1&api-version=7.1" \
  | jq -r '.value[0].downloadUrl')

echo "Agent download URL: $AGENT_URL"

if [ -z "$AGENT_URL" ] || [ "$AGENT_URL" = "null" ]; then
  echo "ERROR: Could not determine agent download URL from API. Exiting."
  exit 1
fi

wget -O agent.tar.gz "$AGENT_URL"
tar zxvf agent.tar.gz
rm agent.tar.gz

# Install agent dependencies
./bin/installdependencies.sh

# Ensure agent directory is owned by azureuser
chown -R azureuser:azureuser /opt/azdo

# Configure the agent as 'azureuser'
echo "=== Configuring agent ==="
sudo -i -u azureuser bash << EOF
cd /opt/azdo/agent
./config.sh --unattended \
  --url "${AZDO_URL}" \
  --auth pat \
  --token "${AZDO_PAT}" \
  --pool "${POOL_NAME}" \
  --agent "${AGENT_NAME}" \
  --acceptTeeEula \
  --work _work \
  --replace
EOF

# Install and start the agent service
echo "=== Installing and starting agent service ==="
./svc.sh install azureuser
./svc.sh start

echo "=== Cloud-init: Agent provisioning complete ==="