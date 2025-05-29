MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash

# Your script here, e.g.:

cluster_name="your-cluster-name"
endpoint="https://your-cluster-endpoint"
cluster_auth_base64="base64-encoded-ca"
cluster_service_cidr="10.100.0.0/16"
kubelet_extra_args="--node-labels=role=worker --max-pods=110"

NODE_LABELS=""
REGISTER_TAINTS=""
MAX_PODS=""

if [[ "${kubelet_extra_args}" == *"--node-labels"* ]]; then
  NODE_LABELS=$(echo "${kubelet_extra_args}" | grep -o "\--node-labels [^ ]*" | cut -d ' ' -f2)
fi
if [[ "${kubelet_extra_args}" == *"--register-with-taints"* ]]; then
  REGISTER_TAINTS=$(echo "${kubelet_extra_args}" | grep -o "\--register-with-taints [^ ]*" | cut -d ' ' -f2)
fi
if [[ "${kubelet_extra_args}" == *"--max-pods"* ]]; then
  MAX_PODS=$(echo "${kubelet_extra_args}" | grep -o "\--max-pods [^ ]*" | cut -d ' ' -f2)
fi

mkdir -p /etc/eks
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

nodeadm join --config-file /etc/eks/nodeconfig.yaml

--BOUNDARY--
