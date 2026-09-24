# Local Validation Notes

## Current Lab

The repository is designed to be validated on a Windows 11 + WSL2 + Docker Desktop environment.

The validation target is a reproducible local Kubernetes lab rather than a production cluster.

## Recommended validation sequence

1. Verify Docker is running.
2. Verify kubectl connectivity.
3. Verify kind and Helm are available.
4. Create the kind cluster.
5. Validate the rendered Helm manifests before installation.
6. Install the release.
7. Inspect pods, services, HPA, PDB, and events.
8. Exercise the failure scenarios.
9. Record findings and remediation in the repository.

## Pre-flight

```bash
docker version
kubectl version --client
kind version
helm version
kubectl config current-context
```

## Helm validation

Before changing the cluster:

```bash
helm lint ./helm
helm template platform-api ./helm --namespace platform
```

This catches chart/template errors before deployment.

## Cluster validation

```bash
./scripts/create-cluster.sh
kubectl get nodes -o wide
kubectl get pods -A
```

## Deployment validation

```bash
./scripts/deploy.sh
kubectl rollout status deployment/platform-api -n platform
kubectl get pods -n platform -o wide
kubectl get svc -n platform
kubectl get hpa -n platform
kubectl get pdb -n platform
kubectl get networkpolicy -n platform
```

## Evidence collection

When something fails, capture:

```bash
kubectl describe deployment platform-api -n platform
kubectl describe pods -n platform
kubectl get events -n platform --sort-by=.lastTimestamp
kubectl get endpoints -n platform
```

The objective is to preserve evidence before making changes.

## Interview Value

The validation process demonstrates more than Kubernetes syntax. It demonstrates a repeatable operational method:

**Pre-flight → Validate → Deploy → Observe → Diagnose → Remediate → Verify**

