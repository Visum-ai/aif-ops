#!/usr/bin/env bash
set -euo pipefail

INSTANCE="${1:-}"

if [[ -z "$INSTANCE" ]]; then
  echo "Usage: ./validate.sh <instance.ttl>"
  exit 1
fi

[[ "$INSTANCE" = /* ]] || INSTANCE="$PWD/$INSTANCE"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -x "$DIR/.venv/bin/pyshacl" ]; then
  PYSHACL_BIN="$DIR/.venv/bin/pyshacl"
elif command -v pyshacl >/dev/null 2>&1; then
  PYSHACL_BIN="pyshacl"
else
  echo "pyshacl not found. Run: pip install pyshacl" >&2
  exit 1
fi

"$PYSHACL_BIN" \
  -s "$DIR/aif_ops_shapes.ttl" \
  -e "$DIR/aif_ops.ttl" \
  -df turtle \
  -f table \
  "$INSTANCE"
