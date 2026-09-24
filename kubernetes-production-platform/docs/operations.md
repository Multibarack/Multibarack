# Operations Guide

## Deploy

```bash
kubectl apply -f namespaces/
kubectl apply -f config/
kubectl apply -f workloads/
kubectl apply -f services/
kubectl apply -f scaling/
kubectl apply -f policies/
kubectl apply -f storage/
```

## Verify

```bash
kubectl get pods -n platform
kubectl get svc -n platform
kubectl get hpa -n platform
kubectl get events -n platform --sort-by=.lastTimestamp
```

## Troubleshooting

### Pod is not ready

```bash
kubectl describe pod -n platform <pod>
kubectl logs -n platform <pod> --previous
kubectl get events -n platform --sort-by=.lastTimestamp
```

Check the readiness probe, container logs, service endpoints, and recent deployment changes.

### CrashLoopBackOff

Start with:

```bash
kubectl describe pod -n platform <pod>
kubectl logs -n platform <pod> --previous
```

Do not immediately delete and recreate the workload. Establish why the container is restarting first.

### HPA is not scaling

Check:

```bash
kubectl describe hpa -n platform platform-api
kubectl top pods -n platform
kubectl get deployment -n platform platform-api
```

The cluster must have a working metrics pipeline for resource-based HPA decisions.

## Operational Principle

When troubleshooting Kubernetes, establish the failure domain first:

**Application → Container → Pod → Service → Network → Node → Cluster**

Change only what the evidence supports.
