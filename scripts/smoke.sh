#!/usr/bin/env bash
# Render every chezmoi template against synthetic linux + darwin personas and
# syntax-check the rendered output. No network, no install — pure template
# correctness check. Used both locally (`just smoke`) and from CI.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi not on PATH; install it first (see bootstrap.sh)." >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cat > "$WORK/cfg-linux.toml" <<'EOF'
[data]
    name           = "CI Bot"
    email          = "ci@omnideck.test"
    machine_kind   = "personal"
    host_name      = "ci-runner"
    install_gui    = true
    install_docker = true
    runtimes       = ["node", "python", "go", "rust", "deno", "bun"]
EOF

cat > "$WORK/cfg-darwin.toml" <<'EOF'
[data]
    name           = "CI Bot"
    email          = "ci@omnideck.test"
    machine_kind   = "personal"
    host_name      = "ci-runner"
    install_gui    = true
    install_docker = true
    runtimes       = ["node", "python", "go", "rust", "deno", "bun"]

[data.chezmoi]
    os = "darwin"
EOF

fail=0
checked=0

while IFS= read -r tmpl; do
  rel="${tmpl#./}"
  # The chezmoi config template uses *Once prompt functions that are only
  # available under `chezmoi init`; verify it via a dedicated --init pass.
  if [[ "$rel" == "home/.chezmoi.toml.tmpl" ]]; then
    if ! chezmoi execute-template --init \
      --promptString name="CI Bot" \
      --promptString email="ci@omnideck.test" \
      --promptChoice machine_kind="personal" \
      --promptString host_name="ci-runner" \
      --promptBool install_gui="true" \
      --promptBool install_docker="true" \
      --promptMultichoice runtimes="node,python" \
      < "$tmpl" >/dev/null 2>"$WORK/err"; then
      echo "  RENDER FAIL (init) $rel"
      sed 's/^/    /' "$WORK/err"
      fail=1
    fi
    checked=$((checked+1))
    continue
  fi
  for persona in linux darwin; do
    out="$WORK/render/${persona}-$(echo "$rel" | tr '/' '_')"
    mkdir -p "$WORK/render"
    if ! chezmoi --config "$WORK/cfg-${persona}.toml" --source home execute-template < "$tmpl" > "$out" 2>"$WORK/err"; then
      echo "  RENDER FAIL ($persona) $rel"
      sed 's/^/    /' "$WORK/err"
      fail=1
      continue
    fi
    case "$tmpl" in
      *.sh.tmpl)
        if ! bash -n "$out" 2>"$WORK/err"; then
          echo "  bash -n FAIL ($persona) $rel"
          sed 's/^/    /' "$WORK/err"
          fail=1
        fi
        ;;
      *zshrc.tmpl|*zshenv.tmpl)
        if command -v zsh >/dev/null 2>&1; then
          if ! zsh -n "$out" 2>"$WORK/err"; then
            echo "  zsh -n FAIL ($persona) $rel"
            sed 's/^/    /' "$WORK/err"
            fail=1
          fi
        fi
        ;;
    esac
    checked=$((checked+1))
  done
done < <(find home -type f -name '*.tmpl')

echo
if [ "$fail" -eq 0 ]; then
  printf '\033[1;32mAll %d renders passed syntax checks.\033[0m\n' "$checked"
else
  printf '\033[1;31mSmoke test failures detected.\033[0m\n'
  exit 1
fi
