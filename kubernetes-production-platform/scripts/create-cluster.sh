#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="platform-lab"

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "Cluster $CLUSTER_NAME already exists."
else
  kind create cluster --config kind/kind-config.yaml
fi

kubectl cluster-info
kubectl get nodes -o wide
