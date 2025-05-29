#!/bin/bash

NODE_LABELS=""
REGISTER_TAINTS=""
MAX_PODS=""

# Parse the kubelet_extra_args string
if [[ "${kubelet_extra_args}" == *"--node-labels"* ]]; then
  NODE_LABELS=$(echo "${kubelet_extra_args}" | grep -o "\--node-labels [^ ]*" | cut -d ' ' -f2)
fi

if [[ "${kubelet_extra_args}" == *"--register-with-taints"* ]]; then
  REGISTER_TAINTS=$(echo "${kubelet_extra_args}" | grep -o "\--register-with-taints [^ ]*" | cut -d ' ' -f2)
fi

if [[ "${kubelet_extra_args}" == *"--max-pods"* ]]; then
  MAX_PODS=$(echo "${kubelet_extra_args}" | grep -o "\--max-pods [^ ]*" | cut -d ' ' -f2)
fi

# Create NodeConfig for nodeadm
cat > /etc/eks/nodeconfig.yaml << EOF
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
    apiServerEndpoint: ${endpoint}
    certificateAuthority: ${cluster_auth_base64}
    cidr: ${cluster_service_cidr}
EOF

# Only add kubelet section if we have flags to add
if [[ -n "$NODE_LABELS" || -n "$REGISTER_TAINTS" || -n "$MAX_PODS" ]]; then
  cat >> /etc/eks/nodeconfig.yaml << EOF
  kubelet:
    flags:
EOF

  if [[ -n "$NODE_LABELS" ]]; then
    echo "      - --node-labels=$NODE_LABELS" >> /etc/eks/nodeconfig.yaml
  fi
  
  if [[ -n "$REGISTER_TAINTS" ]]; then
    echo "      - --register-with-taints=$REGISTER_TAINTS" >> /etc/eks/nodeconfig.yaml
  fi
  
  if [[ -n "$MAX_PODS" ]]; then
    echo "      - --max-pods=$MAX_PODS" >> /etc/eks/nodeconfig.yaml
  fi
fi

# Use nodeadm to join the cluster
nodeadm join --config-file /etc/eks/nodeconfig.yaml