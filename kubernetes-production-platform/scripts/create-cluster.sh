#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="platform-lab"

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "Cluster $CLUSTER_NAME already exists."
else
  kind create cluster \
    --name "$CLUSTER_NAME" \
    --config kind/kind-config.yaml \
    --wait 5m
fi

kubectl cluster-info
kubectl get nodes -o wide
