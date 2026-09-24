# Helm

This directory is reserved for the Helm chart version of the platform.

The chart will package the Deployment, Service, ConfigMap, Secret template, HPA, PDB, NetworkPolicy, and Ingress.

Planned values include replica count, image tag, resource sizing, ingress hostname, and autoscaling thresholds.

The raw manifests remain in the repository because they are useful for reviewing the underlying Kubernetes resources directly.
