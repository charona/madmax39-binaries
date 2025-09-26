#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python -m venv .venv
# shellcheck disable=SC1091
source .venv/Scripts/activate

python -m pip install -U pip
pip install pyinstaller shamir-mnemonic mnemonic "cryptography<43"

rm -rf build "dist/windows-x64"
pyinstaller madmax39.spec --distpath "dist/windows-x64"
echo "✅ Built dist/windows-x64/madmax39.exe"

