# Installation

## Prerequisites

- A Kubernetes cluster (tested with [k3d](https://k3d.io))
- [Helm](https://helm.sh) 3.x
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- (Optional) [devenv](https://devenv.sh) for a reproducible dev shell

## Quick Install

```bash
# Clone the repo
git clone https://github.com/SamuelLHuber/helix-db-helm-chart.git
cd helix-db-helm-chart

# Install the chart
helm install helixdb ./helixdb --namespace helixdb --create-namespace

# Wait for readiness
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=helixdb -n helixdb --timeout=120s

# Verify
./verify.sh
```

## Using devenv

If you use Nix, enter the dev shell:

```bash
direnv allow  # or: devenv shell
```

Then use the helper commands:

```bash
deploy   # Install/upgrade HelixDB on k3d
verify   # Run the full verification suite
```

## Configuration

See `values.yaml` for all tunable parameters. Key values:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `replicaCount` | `1` | HelixDB replicas (must be 1 for single writer) |
| `image.tag` | `latest` | HelixDB image tag |
| `minio.enabled` | `true` | Deploy bundled MinIO |
| `minio.storage.size` | `5Gi` | PVC size for MinIO |
| `minio.bucket` | `helix-db` | S3 bucket name |

## Port-Forwarding

After installation, access HelixDB locally:

```bash
kubectl port-forward svc/helixdb 6969:8080 -n helixdb
```

Access MinIO console:

```bash
kubectl port-forward svc/helixdb-minio 9001:9001 -n helixdb
# Login: minioadmin / minioadmin
```
