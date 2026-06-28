# Querying HelixDB

HelixDB accepts **dynamic JSON queries** via `POST /v1/query`. This is the same wire format used by the HelixDB CLI and SDKs.

## Dynamic Query Format

Every request has this shape:

```json
{
  "request_type": "write" | "read",
  "query": {
    "queries": [
      {
        "Query": {
          "name": "<result_key>",
          "steps": [...],
          "condition": null
        }
      }
    ],
    "returns": ["<result_key>"]
  },
  "parameters": {}
}
```

## Write a Node

```bash
curl -X POST http://localhost:6969/v1/query \
  -H "Content-Type: application/json" \
  -d '{
    "request_type": "write",
    "query": {
      "queries": [{
        "Query": {
          "name": "created",
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
      "returns": ["created"]
    },
    "parameters": {}
  }'
```

**Response:**
```json
{"created": {"ids": [42]}}
```

## Read a Node

```bash
curl -X POST http://localhost:6969/v1/query \
  -H "Content-Type: application/json" \
  -d '{
    "request_type": "read",
    "query": {
      "queries": [{
        "Query": {
          "name": "users",
          "steps": [
            {"NWhere": {"Eq": ["$label", {"String": "User"}]}},
            {"Where": {"Eq": ["name", {"String": "Alice"}]}},
            "Count"
          ],
          "condition": null
        }
      }],
      "returns": ["users"]
    },
    "parameters": {}
  }'
```

**Response:**
```json
{"users": {"count": 1}}
```

## Using the SDKs

For production code, use the HelixDB SDKs instead of hand-writing JSON:

- **TypeScript**: `@helix-db/helix-db`
- **Rust**: `helix-db`
- **Go**: `github.com/HelixDB/helix-db/sdks/go`
- **Python**: `helix-db`

The SDKs generate the exact JSON shown above automatically.

## Further Reading

- [HelixDB Querying Guide](https://docs.helix-db.com/database/querying-guide/overview)
- [HelixDB Dynamic Query JSON Reference](https://docs.helix-db.com/database/querying-guide/dynamic-json)
