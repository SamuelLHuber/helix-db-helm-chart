# 🌀 HelixDB Helm Chart for Kubernetes

> ⚠️ **EXPERIMENTAL**: This is a community-maintained Helm chart. It is **not** officially supported by HelixDB. The `enterprise-dev` image is a single-node engine. For production, high-availability deployments, use [HelixDB Cloud](https://helix-db.com).

Deploy [**HelixDB**](https://github.com/HelixDB/helix-db) — a graph-vector database for knowledge graphs and AI memory — on Kubernetes with **S3-compatible persistent storage** via MinIO.

## ✨ Features

- **One-command deploy** to any Kubernetes cluster (tested on k3d)
- **S3-backed persistence** — data survives pod restarts
- **Bundled MinIO** — no external dependencies needed
- **End-to-end verification** — automated tests that write, read, and confirm durability
- **Reproducible dev shell** via [devenv](https://devenv.sh)

## 🚀 Quick Start

```bash
# Clone
git clone https://github.com/SamuelLHuber/helix-db-helm-chart.git
cd helix-db-helm-chart

# Install (requires a K8s cluster — k3d recommended)
helm install helixdb ./helixdb --namespace helixdb --create-namespace

# Wait for readiness
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=helixdb -n helixdb --timeout=120s

# Verify everything works
./verify.sh
```

Example output:
```
✅ SUCCESS: HelixDB is writing and reading correctly on k3d with S3-backed persistence!
```

## 📖 Documentation

| Guide | Description |
|-------|-------------|
| [Installation](docs/installation.md) | Full install instructions, configuration, and port-forwarding |
| [Architecture](docs/architecture.md) | How the chart works, data flow, and persistence model |
| [Querying](docs/querying.md) | Writing dynamic JSON queries and using the SDKs |
| [Contributing](CONTRIBUTING.md) | Development setup, workflow, and testing checklist |

## 🛠️ Writing and Querying

Port-forward the service:
```bash
kubectl port-forward svc/helixdb 6969:8080 -n helixdb
```

### Write a node
```bash
curl -X POST http://localhost:6969/v1/query \
  -H "Content-Type: application/json" \
  -d '{
    "request_type": "write",
    "query": {
      "queries": [{
        "Query": {
          "name": "addUser",
          "steps": [{
            "AddN": {
              "label": "User",
              "properties": [
                ["name", {"Value": {"String": "Alice"}}],
                ["email", {"Value": {"String": "alice@example.com"}}]
              ],
              "vector": null
            }
          }],
          "condition": null
        }
      }],
      "returns": ["addUser"]
    },
    "parameters": {}
  }'
```

### Read it back
```bash
curl -X POST http://localhost:6969/v1/query \
  -H "Content-Type: application/json" \
  -d '{
    "request_type": "read",
    "query": {
      "queries": [{
        "Query": {
          "name": "getUser",
          "steps": [
            {"NWhere": {"Eq": ["$label", {"String": "User"}]}},
            {"Where": {"Eq": ["name", {"String": "Alice"}]}},
            "Count"
          ],
          "condition": null
        }
      }],
      "returns": ["getUser"]
    },
    "parameters": {}
  }'
```

## 🔍 Inspecting S3 Storage

Port-forward MinIO console:
```bash
kubectl port-forward svc/helixdb-minio 9001:9001 -n helixdb
# Open http://localhost:9001 (login: minioadmin / minioadmin)
```

You will see WAL, manifest, and SST files in the `helix-db/db/` bucket — proof that your data is durably persisted.

## 📁 Repository Structure

```
helixdb/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration
├── templates/
│   ├── _helpers.tpl        # Template helpers
│   ├── helixdb.yaml        # HelixDB Deployment + Service
│   ├── minio.yaml          # MinIO Deployment + PVC + Service
│   ├── minio-setup-job.yaml # Helm hook: creates S3 bucket
│   ├── NOTES.txt           # Post-install instructions
│   └── tests/
│       └── test-query.yaml # Helm test: writes + reads a node
docs/
├── architecture.md         # How it works
├── installation.md         # Install guide
└── querying.md             # Query guide
verify.sh                   # Standalone end-to-end validation
```

## ⚠️ Important Notes

1. **Single-node only**: The `enterprise-dev` image is a single writer. Do not scale `replicaCount` above 1.
2. **Not for production HA**: True clustering (multi-gateway, auto-scaling readers) requires HelixDB Cloud.
3. **Image terms**: The `enterprise-dev` image is publicly pullable but its license terms are not documented here. Contact HelixDB for commercial use.
4. **Data loss on uninstall**: Uninstalling the Helm chart deletes the MinIO PVC. Back up your bucket first if data matters.

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development setup using devenv, testing workflow, and PR guidelines.

```bash
# Quick dev setup
direnv allow   # or: devenv shell
deploy         # Install/upgrade on k3d
verify         # Run full validation
```

## 📄 License

MIT — see [LICENSE](LICENSE).

## 🔗 Links

- [HelixDB](https://helix-db.com)
- [HelixDB Documentation](https://docs.helix-db.com)
- [HelixDB GitHub](https://github.com/HelixDB/helix-db)
- [devenv](https://devenv.sh)
