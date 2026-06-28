{
  pkgs,
  lib,
  config,
  ...
}:
{
  name = "helix-db-helm-chart";

  packages = [
    # Kubernetes tooling
    pkgs.k3d
    pkgs.kubectl
    pkgs.kubernetes-helm

    # Container tooling
    pkgs.docker-client

    # General utilities
    pkgs.curl
    pkgs.jq
    pkgs.yq
    pkgs.envsubst
    pkgs.gnumake
    pkgs.gnused
    pkgs.gnugrep
    pkgs.coreutils
    pkgs.findutils
    pkgs.which
    pkgs.tree
    pkgs.git
    pkgs.jujutsu

    # Documentation
    pkgs.mdbook
  ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks = {
    helmlint = {
      enable = true;
      name = "helm-lint";
      entry = "${pkgs.kubernetes-helm}/bin/helm lint ./helixdb";
      files = "\\.(yaml|yml|tpl)$";
      pass_filenames = false;
    };
    shellcheck = {
      enable = true;
      name = "shellcheck";
      entry = "${pkgs.shellcheck}/bin/shellcheck";
      files = "\\.sh$";
    };
    markdownlint = {
      enable = true;
      name = "markdownlint";
      entry = "${pkgs.markdownlint-cli}/bin/markdownlint";
      files = "\\.md$";
    };
    trailing-whitespace = {
      enable = true;
      name = "trailing-whitespace";
      entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
    };
    end-of-file-fixer = {
      enable = true;
      name = "end-of-file-fixer";
      entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/end-of-file-fixer";
    };
  };

  # https://devenv.sh/scripts/
  scripts.deploy.exec = ''
    echo "Deploying HelixDB to k3d..."
    helm upgrade --install helixdb ./helixdb --namespace helixdb --create-namespace
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=helixdb -n helixdb --timeout=120s
    echo "Deployment complete. Run './verify.sh' to validate."
  '';

  scripts.verify.exec = ''
    ./verify.sh
  '';

  enterShell = ''
    echo "🌀 HelixDB Helm Chart dev environment"
    echo ""
    echo "Available commands:"
    echo "  deploy   — Install/upgrade HelixDB on k3d"
    echo "  verify   — Run the full verification suite"
    echo "  helm lint ./helixdb"
    echo ""
    echo "Docs: https://docs.helix-db.com"
    echo "Repo: https://github.com/SamuelLHuber/helix-db-helm-chart"
  '';
}
