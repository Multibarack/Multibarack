# Architecture

## Request path

Client -> Ingress Controller -> ClusterIP Service -> Application Pods

## Scaling path

Application workload -> Resource metrics -> HPA -> Deployment replica count -> Kubernetes scheduler -> Pods

## Reliability controls

- Multiple replicas
- RollingUpdate strategy
- Readiness/liveness/startup probes
- Resource requests and limits
- HPA
- PodDisruptionBudget
- NetworkPolicy
- Restricted pod security settings
- Namespace quotas
- Ingress

The platform separates application availability, scheduling, scaling, security, and traffic-management concerns so each can be diagnosed independently.
