---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
    apiServerEndpoint: ${endpoint}
    certificateAuthority: ${cluster_auth_base64}
    cidr: ${cluster_service_cidr}
  kubelet:
    flags:
      - --node-labels ${join(",", node_labels)}
%{ if length(taints) > 0 }
      - --register-with-taints ${join(",", taints)}
%{ endif }
%{ if max_pods != null }
      - --max-pods ${max_pods}
%{ endif }
