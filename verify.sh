#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-helixdb}"
RELEASE="${RELEASE:-helixdb}"

echo "=== HelixDB k3d Verification Script ==="
echo ""

# 1. Check pods
echo "1. Checking pods..."
kubectl get pods -n "$NAMESPACE"
echo ""

# 2. Run Helm tests
echo "2. Running Helm tests..."
helm test "$RELEASE" -n "$NAMESPACE" --timeout 120s
echo ""

# 3. Port-forward and demonstrate write + read
echo "3. Port-forwarding HelixDB to localhost:6969..."
kubectl port-forward "svc/$RELEASE" 6969:8080 -n "$NAMESPACE" &
PF_PID=$!
sleep 3

cleanup() {
  kill $PF_PID 2>/dev/null || true
}
trap cleanup EXIT

echo "4. Writing a node..."
WRITE_RESP=$(curl -sf -X POST http://localhost:6969/v1/query \
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
                ["name", {"Value": {"String": "TestUser"}}],
                ["email", {"Value": {"String": "test@example.com"}}]
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
  }')
echo "Write response: $WRITE_RESP"

echo ""
echo "5. Reading the node back..."
READ_RESP=$(curl -sf -X POST http://localhost:6969/v1/query \
  -H "Content-Type: application/json" \
  -d '{
    "request_type": "read",
    "query": {
      "queries": [{
        "Query": {
          "name": "getUser",
          "steps": [
            {"NWhere": {"Eq": ["$label", {"String": "User"}]}},
            {"Where": {"Eq": ["name", {"String": "TestUser"}]}},
            "Count"
          ],
          "condition": null
        }
      }],
      "returns": ["getUser"]
    },
    "parameters": {}
  }')
echo "Read response: $READ_RESP"

if echo "$READ_RESP" | grep -q '"count":[1-9]'; then
  echo ""
  echo "✅ SUCCESS: HelixDB is writing and reading correctly on k3d with S3-backed persistence!"
else
  echo ""
  echo "❌ FAILURE: Data did not persist or query failed"
  exit 1
fi

echo ""
echo "6. MinIO bucket contents (S3 storage):"
kubectl exec "deploy/${RELEASE}-minio" -n "$NAMESPACE" -- \
  sh -c 'mc alias set local http://localhost:9000 minioadmin minioadmin >/dev/null 2>&1 && mc ls local/helix-db --recursive' | tail -10 || true

echo ""
echo "=== Verification complete ==="
