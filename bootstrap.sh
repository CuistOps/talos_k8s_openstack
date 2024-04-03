#!/bin/bash
echo -e "\n# \e[1;34mInstall made by \e[1;31m@PAPAMICA__ \e[1;34mwith documentation of \e[1;31m@TheBidouilleur \e[0m\n\e[0m
\e[32m# Documentation (in french) : https://une-tasse-de.cafe/blog/talos/\e[0m\n\e[0m
\e[32m# Infomaniak Public Cloud's documentation : https://docs.infomaniak.cloud/\e[0m\n\e[0m
\e[36m# Follow the commands below to install the cluster:\e[0m\n\e[0m
# Generate secrets
\e[33mtalosctl gen secrets\n\e[0m
# Generate configuration for the cluster
\e[33mtalhelper genconfig\n\e[0m
# Apply control plane configuration to nodes
\e[33mtalosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.10.0.11 --file=./clusterconfig/cuistops-dev-controlplane-01.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.10.0.12 --file=./clusterconfig/cuistops-dev-controlplane-02.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.10.0.13 --file=./clusterconfig/cuistops-dev-controlplane-03.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.10.0.51 --file=./clusterconfig/cuistops-dev-worker-01.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.10.0.52 --file=./clusterconfig/cuistops-dev-worker-02.yaml --insecure;\n\e[0m
# Configure endpoints and nodes
\e[33mtalosctl config merge ./clusterconfig/talosconfig\n\e[0m
# Check system messages
\e[33mtalosctl dmesg\n\e[0m
# Bootstrap the cluster
\e[33mtalosctl bootstrap -e 10.10.0.11 --nodes 10.10.0.11\n\e[0m
# Retrieve kubeconfig for the cluster
\e[33mtalosctl kubeconfig -e 10.10.0.11 --nodes 10.10.0.11\n\e[0m
# Verify nodes are ready
\e[33mkubectl get nodes\n\e[0m
# Install cilium CNI
\e[33mkubectl apply -f cilium.yaml\n\e[0m" > /etc/motd

# Installer Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Installer Cilium CLI
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

helm repo add cilium https://helm.cilium.io/

helm template \
    cilium \
    cilium/cilium \
    --version 1.15.1 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set=kubeProxyReplacement=true \
    --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set=cgroup.autoMount.enabled=false \
    --set=cgroup.hostRoot=/sys/fs/cgroup \
    --set=k8sServiceHost=localhost \
    --set=k8sServicePort=7445 \
    --set=l2announcements.enabled=true \
    --set=l2announcements.leaseDuration="300s" \
    --set=l2announcements.leaseRenewDeadline="60s" \
    --set=l2announcements.leaseRetryPeriod="10s" \
    --set=externalIPs.enabled=true \
    --set gatewayAPI.enabled=true \
    --set=k8sClientRateLimit.qps=50 \
    --set=k8sClientRateLimit.burst=100 > /home/debian/cilium.yaml

su debian
cd /home/debian

# Installer Talos
curl -sL https://talos.dev/install | sh

# Installer kubectl, k9s et talhelper
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
sudo wget -qO- https://github.com/derailed/k9s/releases/download/v0.32.3/k9s_Linux_amd64.tar.gz | sudo tar xvz -C /usr/local/bin/
curl https://i.jpillora.com/budimanjojo/talhelper! | sudo bash



cat > /home/debian/talconfig.yaml <<EOF
---
clusterName: cuistops-dev
talosVersion: v1.6.5
kubernetesVersion: v1.29.1
endpoint: https://10.10.0.11:6443
allowSchedulingOnMasters: true
cniConfig:
  name: none
patches:
  - |-
    - op: add
      path: /cluster/discovery/enabled
      value: true
    - op: replace
      path: /machine/network/kubespan
      value:
        enabled: true
    - op: add
      path: /machine/kubelet/extraArgs
      value:
        rotate-server-certificates: true
    - op: add
      path: /machine/files
      value:
      - content: |
          [metrics]
            address = "0.0.0.0:11234"        
        path: /var/cri/conf.d/metrics.toml
        op: create
nodes:
  - hostname: controlplane-01
    ipAddress: 10.10.0.11
    controlPlane: true
    installDisk: /dev/vda
  - hostname: controlplane-02
    ipAddress: 10.10.0.12
    controlPlane: true
    installDisk: /dev/vda
  - hostname: controlplane-03
    ipAddress: 10.10.0.13
    controlPlane: true
    installDisk: /dev/vda
  - hostname: worker-01
    ipAddress: 10.10.0.51
    installDisk: /dev/vda
  - hostname: worker-02
    ipAddress: 10.10.0.52
    installDisk: /dev/vda

controlPlane:
  patches:
    - |-
      - op: add
        path: /cluster/apiServer/certSANs
        value: 
          - talos-cuistops-cluster
      - op: add
        path: /cluster/proxy/disabled
        value: true
EOF
