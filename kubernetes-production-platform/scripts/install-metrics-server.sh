#!/usr/bin/env bash
set -euo pipefail

METRICS_SERVER_MANIFEST="https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
CLUSTER_NAME="platform-lab"

echo "==> Installing Metrics Server"
kubectl apply -f "$METRICS_SERVER_MANIFEST"

CURRENT_CONTEXT="$(kubectl config current-context)"

if [[ "$CURRENT_CONTEXT" == "kind-${CLUSTER_NAME}" ]]; then
  echo "==> Applying Kind-only kubelet TLS workaround"

  kubectl patch deployment metrics-server -n kube-system --type='strategic' -p='{"spec":{"template":{"spec":{"containers":[{"name":"metrics-server","args":["--cert-dir=/tmp","--secure-port=10250","--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname","--kubelet-use-node-status-port","--metric-resolution=15s","--kubelet-insecure-tls"]}]}}}}'
else
  echo "==> Non-Kind cluster detected; skipping --kubelet-insecure-tls"
fi

echo "==> Waiting for Metrics Server"
kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s

echo "==> Metrics Server status"
kubectl get pods -n kube-system -l k8s-app=metrics-server
