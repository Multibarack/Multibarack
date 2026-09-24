#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="platform"
RELEASE="platform-api"
INGRESS_NAMESPACE="ingress-nginx"
INGRESS_MANIFEST="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
INGRESS_NODE="platform-lab-control-plane"

echo "==> Installing NGINX Ingress Controller"

kubectl apply -f "$INGRESS_MANIFEST"

kubectl -n "$INGRESS_NAMESPACE" patch deployment ingress-nginx-controller \
  --type='strategic' \
  -p="{\"spec\":{\"template\":{\"spec\":{\"nodeSelector\":{\"kubernetes.io/hostname\":\"$INGRESS_NODE\"}}}}}"

kubectl rollout status deployment/ingress-nginx-controller \
  -n "$INGRESS_NAMESPACE" \
  --timeout=180s

echo "==> Deploying platform"

kubectl apply -f namespaces/platform.yaml

helm upgrade --install "$RELEASE" ./helm \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --wait \
  --timeout 5m

echo "==> Platform status"

kubectl get pods -n "$NAMESPACE"
kubectl get svc -n "$NAMESPACE"
kubectl get ingress -n "$NAMESPACE"
kubectl get hpa -n "$NAMESPACE"
kubectl get pdb -n "$NAMESPACE"
kubectl get networkpolicy -n "$NAMESPACE"
