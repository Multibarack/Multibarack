#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="platform"
RELEASE="platform-api"
INGRESS_HOST="platform-api.local"
INGRESS_URL="http://localhost:8080/"

echo "==> Helm lint"
helm lint ./helm

echo "==> Helm template validation"
helm template "$RELEASE" ./helm --namespace "$NAMESPACE" >/tmp/platform-api-rendered.yaml

echo "==> Checking rendered resources"
grep -q "kind: Deployment" /tmp/platform-api-rendered.yaml
grep -q "kind: Service" /tmp/platform-api-rendered.yaml
grep -q "kind: Ingress" /tmp/platform-api-rendered.yaml
grep -q "kind: HorizontalPodAutoscaler" /tmp/platform-api-rendered.yaml
grep -q "kind: PodDisruptionBudget" /tmp/platform-api-rendered.yaml
grep -q "kind: NetworkPolicy" /tmp/platform-api-rendered.yaml
grep -q "kind: ResourceQuota" /tmp/platform-api-rendered.yaml
grep -q "kind: LimitRange" /tmp/platform-api-rendered.yaml
grep -q "kind: Secret" /tmp/platform-api-rendered.yaml

echo "==> Checking deployment rollout"
kubectl rollout status deployment/platform-api \
  -n "$NAMESPACE" \
  --timeout=120s

echo "==> Checking platform resources"
kubectl get pods -n "$NAMESPACE" -o wide
kubectl get svc -n "$NAMESPACE"
kubectl get ingress -n "$NAMESPACE"
kubectl get hpa -n "$NAMESPACE"
kubectl get pdb -n "$NAMESPACE"
kubectl get networkpolicy -n "$NAMESPACE"
kubectl get resourcequota -n "$NAMESPACE"
kubectl get limitrange -n "$NAMESPACE"
kubectl get secret -n "$NAMESPACE"

echo "==> Checking Metrics API"
METRICS_API_STATUS="$(
  kubectl get apiservice v1beta1.metrics.k8s.io \
    -o jsonpath='{.status.conditions[?(@.type=="Available")].status}'
)"

if [[ "$METRICS_API_STATUS" != "True" ]]; then
  echo "Metrics API is not available"
  exit 1
fi

echo "Metrics API is available"

echo "==> Checking pod metrics"
kubectl top pods -n "$NAMESPACE"

echo "==> Checking HPA metrics"
HPA_TARGETS="$(
  kubectl get hpa platform-api \
    -n "$NAMESPACE" \
    -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}'
)"

if [[ -z "$HPA_TARGETS" ]]; then
  echo "HPA CPU metrics are unavailable"
  exit 1
fi

echo "HPA CPU metrics are available: ${HPA_TARGETS}%"
kubectl get hpa platform-api -n "$NAMESPACE"

echo "==> Checking ingress configuration"
INGRESS_CONFIGURED_HOST="$(
  kubectl get ingress platform-api \
    -n "$NAMESPACE" \
    -o jsonpath='{.spec.rules[0].host}'
)"

if [[ "$INGRESS_CONFIGURED_HOST" != "$INGRESS_HOST" ]]; then
  echo "Unexpected ingress host: $INGRESS_CONFIGURED_HOST"
  exit 1
fi

echo "Ingress host verified: $INGRESS_CONFIGURED_HOST"

echo "==> HTTP smoke test"
HTTP_STATUS="$(
  curl -sS -o /tmp/platform-api-response.html \
    -w '%{http_code}' \
    -H "Host: $INGRESS_HOST" \
    "$INGRESS_URL"
)"

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "HTTP smoke test failed with status: $HTTP_STATUS"
  exit 1
fi

echo "HTTP smoke test passed with status: $HTTP_STATUS"

echo
echo "==> Validation successful"
