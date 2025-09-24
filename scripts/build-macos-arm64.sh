#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Prefer Homebrew Python on Apple Silicon
export PATH="/opt/homebrew/bin:$PATH"

python3 -m venv .venv --upgrade-deps
source .venv/bin/activate

python -m pip install -U pip
pip install pyinstaller shamir-mnemonic mnemonic cryptography

rm -rf build dist/macos-arm64
pyinstaller madmax39.spec --distpath dist/macos-arm64 --name madmax
echo "✅ Built dist/macos-arm64/madmax"

