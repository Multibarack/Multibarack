# Kubernetes Production Platform

A production-inspired Kubernetes platform demonstrating how I approach workload reliability, scaling, networking, configuration, security, and day-2 operations.

> This is a sanitized engineering lab. It contains no confidential enterprise configuration, credentials, customer data, or proprietary source code.

## Objectives

- Deploy a realistic multi-component application to Kubernetes
- Separate workloads with namespaces
- Apply resource requests and limits
- Implement startup, readiness, and liveness probes
- Expose services through Kubernetes networking
- Configure horizontal scaling with HPA
- Use ConfigMaps and Secrets correctly
- Apply NetworkPolicies using least-privilege principles
- Demonstrate persistent storage where state requires it
- Provide operational documentation for troubleshooting

## Architecture

The initial platform uses:

- Kubernetes
- NGINX ingress
- Application Deployment
- Internal Service
- ConfigMap
- Secret
- HorizontalPodAutoscaler
- NetworkPolicy
- PersistentVolumeClaim
- Resource quotas and limits

The manifests are intentionally modular so individual components can be reviewed without requiring a full platform installation.

## Repository Structure

```text
kubernetes-production-platform/
├── README.md
├── namespaces/
├── workloads/
├── services/
├── config/
├── networking/
├── scaling/
├── storage/
├── policies/
└── docs/
```

## Operational Principles

### Reliability

Applications should not be considered healthy simply because their process is running. Readiness and liveness are treated as separate operational signals.

### Capacity

Resource requests and limits are defined deliberately so Kubernetes scheduling and workload behavior are predictable.

### Scaling

Horizontal scaling is driven by measurable resource pressure rather than manually increasing replicas.

### Security

Workloads should receive only the network and Kubernetes permissions they require.

### Observability

Every workload should expose enough information to answer:

1. Is it running?
2. Is it ready to receive traffic?
3. Is it under resource pressure?
4. Are requests failing?
5. Has the deployment changed recently?

## Planned Failure Scenarios

This lab will also document controlled failure scenarios such as:

- Readiness probe failures
- CrashLoopBackOff
- OOMKilled containers
- Unschedulable pods
- HPA scaling behavior
- Service connectivity failures
- NetworkPolicy blocking traffic
- Persistent volume issues
- Failed rolling deployments

Each scenario will follow:

**Symptom → Investigation → Root Cause → Remediation → Prevention**

## Environment

Designed to run on a local Kubernetes environment such as:

- kind
- Docker Desktop Kubernetes
- Minikube

It can also be adapted to managed Kubernetes platforms such as Amazon EKS.

## Status

🚧 Initial platform structure — implementation in progress.
