#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

rm -f dist/SHA256SUMS
( cd dist && find . -type f \( -name "madmax" -o -name "madmax39" -o -name "madmax39.exe" \) -exec shasum -a 256 "{}" \; ) > dist/SHA256SUMS
echo "✅ Wrote dist/SHA256SUMS"

