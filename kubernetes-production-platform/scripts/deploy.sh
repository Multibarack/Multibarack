#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="platform"
RELEASE="platform-api"

kubectl apply -f namespaces/platform.yaml

helm upgrade --install "$RELEASE" ./helm \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --wait \
  --timeout 5m

kubectl get pods -n "$NAMESPACE"
kubectl get svc -n "$NAMESPACE"
kubectl get hpa -n "$NAMESPACE"
