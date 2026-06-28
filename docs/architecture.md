# Architecture

## Overview

This Helm chart deploys **HelixDB** on Kubernetes with **S3-compatible persistent storage** via MinIO. It is designed for local development, testing, and small-scale self-hosted deployments.

## Components

```
┌─────────────────────────────────────────────────────────────┐
│                         Kubernetes Cluster                   │
│                                                              │
│  ┌─────────────────┐       ┌─────────────────────────────┐  │
│  │   HelixDB Pod   │◄─────►│        MinIO Pod            │  │
│  │  (enterprise-dev)│       │  S3-compatible object store │  │
│  │   Port: 8080    │       │     Ports: 9000, 9001       │  │
│  └─────────────────┘       └─────────────────────────────┘  │
│         │                              │                     │
│         ▼                              ▼                     │
│  ┌─────────────────┐       ┌─────────────────────────────┐  │
│  │  Service: 8080  │       │  PVC: helixdb-minio-data    │  │
│  └─────────────────┘       └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### HelixDB

- Image: `ghcr.io/helixdb/enterprise-dev:latest`
- Port: `8080`
- Protocol: HTTP JSON (`POST /v1/query`)
- Storage: Writes manifest, WAL, and SST files to S3 (MinIO)
- Init Container: Ensures MinIO is reachable and the bucket exists before starting

### MinIO

- Image: `minio/minio:latest`
- Ports: `9000` (S3 API), `9001` (Console)
- Storage: PVC (`helixdb-minio-data`) for durability
- Bucket: `helix-db`
- Hook Job: Helm post-install hook creates the bucket automatically

## Data Flow

1. **Write**: Client sends a dynamic JSON query to `POST /v1/query`
2. **Process**: HelixDB processes the query and appends to its WAL
3. **Flush**: Periodically, HelixDB flushes memtables and compactions to S3
4. **Read**: On restart, HelixDB reads the manifest from S3 and replays WAL

## Persistence Model

HelixDB uses an **S3-backed log-structured merge tree (LSM)** architecture:

- **Manifest**: Tracks database state and file pointers
- **WAL (Write-Ahead Log)**: Sequential writes for durability
- **SST Files**: Immutable sorted string tables for reads
- **Compactions**: Background process that merges SST files

All of these objects are stored in the MinIO bucket under the `db/` prefix. If the HelixDB pod is deleted, the new pod connects to the same bucket and restores its state.
