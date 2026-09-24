# Controlled Failure Scenarios

These scenarios are intended for a local lab. They demonstrate investigation rather than blindly restarting workloads.

## 1. Readiness Failure

Change the readiness path to an endpoint that does not exist.

Use `kubectl get pods -n platform` to identify the actual pod name, then inspect the pod and Service endpoints.

Expected result: the pod can remain Running while Kubernetes removes it from ready Service endpoints.

## 2. Resource Pressure

Temporarily reduce the memory limit and run a workload that exceeds it. Inspect the pod status and container last state for `OOMKilled`.

## 3. NetworkPolicy Denial

Apply a restrictive policy and test connectivity from an unauthorized namespace. Inspect the NetworkPolicy and determine whether traffic is blocked at the network-policy layer rather than at the application.

## 4. Unschedulable Workload

Temporarily request resources that exceed available node capacity. Inspect the Pending pod and namespace events for the scheduling constraint.

## 5. Failed Rolling Deployment

Deploy an invalid image tag. Inspect rollout status, rollout history, and Deployment details. Recovery can be performed with `kubectl rollout undo deployment/platform-api -n platform`.

Document the failure, evidence, remediation, and prevention rather than treating rollback as the entire RCA.

---

# Observed During Lab Build

These incidents occurred during the actual construction and validation of this platform.

## 6. Ingress 504 Caused by NetworkPolicy

### Symptom

Requests through the NGINX Ingress Controller returned HTTP 504.

### Investigation

The ingress controller logs showed an upstream connection timeout while attempting to reach the application backend. The application pods were Running and the Kubernetes Service existed.

### Root Cause

The NetworkPolicy did not allow traffic from the `ingress-nginx` namespace.

### Remediation

The policy was updated to allow ingress from the NGINX Ingress Controller namespace using the Kubernetes namespace metadata label `kubernetes.io/metadata.name: ingress-nginx`.

### Verification

The original request was repeated with `curl -v -H "Host: platform-api.local" http://localhost:8080/` and returned HTTP 200.

### Lesson

A healthy pod does not prove that the complete request path is healthy.

The troubleshooting path was: Client → Ingress → NetworkPolicy → Service → Pod.

## 7. Metrics Server Unavailable on Kind

### Symptom

The HPA initially reported missing resource metrics and `kubectl top pods` reported that the Metrics API was unavailable.

### Investigation

Metrics Server logs showed kubelet scraping failures caused by certificate validation. The error indicated that the node IP could not be validated because it was not present as an IP SAN in the certificate.

### Root Cause

The local kind node certificates did not contain the node IP addresses as valid IP SANs for Metrics Server kubelet TLS verification.

### Remediation

The local lab installer applies `--kubelet-insecure-tls` only when the active context is the `platform-lab` kind cluster. This is a local kind compatibility workaround, not a general production recommendation.

### Verification

After remediation, the Metrics API became available, `kubectl top pods -n platform` returned live metrics, and the HPA reported live CPU metrics.

### Lesson

When an HPA reports missing metrics, investigate the metrics pipeline before changing the HPA itself.

The diagnostic path was: HPA → Metrics API → Metrics Server → Kubelet → TLS verification.

---

# Failure Investigation Pattern

The observed incidents reinforce the same operational approach:

1. Identify the user-visible symptom.
2. Determine which Kubernetes layer owns the failure.
3. Inspect logs, events, resource status, and configuration.
4. Establish the root cause from evidence.
5. Apply the smallest appropriate remediation.
6. Repeat the original failing test.
7. Record the result and prevention measure.

The objective is not simply to restore service. It is to understand why the failure occurred and leave behind a reproducible operational record.
