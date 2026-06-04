#!/usr/bin/env bash
set -euo pipefail

INSTANCE="${1:-}"

if [[ -z "$INSTANCE" ]]; then
  echo "Usage: ./validate.sh <instance.ttl>"
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/.venv/bin/pyshacl" \
  -s "$DIR/aif_ops_shapes.ttl" \
  -e "$DIR/aif_ops.ttl" \
  -df turtle \
  -f table \
  "$INSTANCE"
