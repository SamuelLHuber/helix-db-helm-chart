# Contributing to helix-db-helm-chart

Thank you for your interest in making this chart better! All contributions are welcome.

## Development Setup

This project uses [devenv](https://devenv.sh) for a fully reproducible development environment.

### Prerequisites

- [Nix](https://nixos.org/download.html) (with flakes enabled)
- [direnv](https://direnv.net) (optional but recommended)

### Enter the dev shell

```bash
# With direnv
cd helix-db-helm-chart
direnv allow

# Without direnv
devenv shell
```

### Available tools

| Tool | Purpose |
|------|---------|
| `k3d` | Local Kubernetes clusters |
| `kubectl` | Kubernetes CLI |
| `helm` | Package manager for Kubernetes |
| `docker` | Container CLI |
| `jq` / `yq` | JSON/YAML processing |
| `jj` | Jujutsu VCS (preferred) |
| `git` | Git VCS |
| `mdbook` | Documentation builder |

## Development Workflow

### 1. Make changes

Edit chart templates, values, docs, or scripts.

### 2. Lint the chart

```bash
helm lint ./helixdb
```

### 3. Test on k3d

```bash
# The dev shell provides a `deploy` script
deploy

# Verify everything works
verify
```

### 4. Commit via jj

This project uses [Jujutsu](https://github.com/martinvonz/jj) for version control. You can also use git if you prefer.

```bash
# Stage all changes
jj st
jj describe -m "feat: add my cool feature"

# Push to a branch
jj git push --remote=origin --branch=my-feature
```

### 5. Open a Pull Request

Use the GitHub CLI:

```bash
gh pr create --title "feat: my cool feature" --body "Description of changes"
```

## Chart Guidelines

- **Templates** should use `{{- include "helixdb.fullname" . }}` for resource names
- **Labels** must follow Kubernetes conventions (`app.kubernetes.io/name`, etc.)
- **Values** should have sensible defaults and be documented in `values.yaml`
- **Tests** in `templates/tests/` should verify the deployment actually works
- **Secrets** should be injected via environment variables, never hardcoded

## Testing Checklist

Before opening a PR, verify:

- [ ] `helm lint ./helixdb` passes
- [ ] `helm template ./helixdb` renders correctly
- [ ] Fresh install on k3d succeeds
- [ ] `helm test` passes
- [ ] Data persists after pod deletion
- [ ] MinIO bucket contains WAL/manifest files
- [ ] `verify.sh` passes end-to-end

## Code of Conduct

Be respectful, constructive, and helpful. We are all here to learn and improve.

## License

MIT — see [LICENSE](LICENSE) for details.
