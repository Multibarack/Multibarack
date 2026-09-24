# Local Lab

## Prerequisites

Install:

- Docker
- kind
- kubectl
- Helm

## Create the cluster

From the project directory:

```bash
chmod +x scripts/*.sh
./scripts/create-cluster.sh
```

## Deploy

```bash
./scripts/deploy.sh
```

## Verify

```bash
kubectl get all -n platform
kubectl get hpa -n platform
kubectl get pdb -n platform
kubectl get networkpolicy -n platform
```

## Access

For a local test, map the ingress hostname to localhost in your hosts file and use the ingress controller appropriate to the local cluster.

If an ingress controller is not installed, port-forward the service instead:

```bash
kubectl port-forward -n platform svc/platform-api 8080:80
```

Then browse to http://localhost:8080.

## Clean up

```bash
./scripts/destroy.sh
```

The lab is intentionally reproducible: create the cluster, deploy the chart, inspect behavior, run failure scenarios, and destroy the environment.
