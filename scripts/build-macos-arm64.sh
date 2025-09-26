#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="/opt/homebrew/bin:$PATH"   # Homebrew Python on Apple Silicon

python3 -m venv .venv --upgrade-deps
source .venv/bin/activate

python -m pip install -U pip
pip install pyinstaller shamir-mnemonic mnemonic cryptography

rm -rf build dist/macos-arm64
pyinstaller madmax39.spec --distpath dist/macos-arm64

echo "✅ Built dist/macos-arm64/madmax39"
