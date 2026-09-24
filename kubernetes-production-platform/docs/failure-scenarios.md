# Controlled Failure Scenarios

These scenarios are intended for a local lab. They demonstrate investigation rather than blindly restarting workloads.

## 1. Readiness failure

Change the readiness path to an endpoint that does not exist.

```bash
kubectl get pods -n platform
kubectl describe pod -n platform <pod>
kubectl get endpoints -n platform platform-api
```

Expected result: the pod can remain Running while Kubernetes removes it from ready service endpoints.

## 2. Resource pressure

Temporarily reduce the memory limit and run a workload that exceeds it.

```bash
kubectl describe pod -n platform <pod>
kubectl get pod -n platform <pod> -o jsonpath='{.status.containerStatuses[*].lastState}'
```

Look for OOMKilled.

## 3. NetworkPolicy denial

Apply a restrictive policy and test connectivity from an unauthorized namespace.

```bash
kubectl get networkpolicy -n platform
kubectl describe networkpolicy -n platform platform-api-ingress
kubectl run debug --rm -it --image=curlimages/curl -- sh
```

Determine whether traffic is blocked at the network-policy layer rather than at the application.

## 4. Unschedulable workload

Temporarily request resources that exceed available node capacity.

```bash
kubectl get pods -n platform
kubectl describe pod -n platform <pod>
kubectl get events -n platform --sort-by=.lastTimestamp
```

Expected symptom: Pending with scheduling events explaining the constraint.

## 5. Failed rolling deployment

Deploy an invalid image tag.

```bash
kubectl rollout status deployment/platform-api -n platform
kubectl rollout history deployment/platform-api -n platform
kubectl describe deployment platform-api -n platform
```

Recovery:

```bash
kubectl rollout undo deployment/platform-api -n platform
```

Document the failure, evidence, remediation, and prevention rather than treating rollback as the entire RCA.
