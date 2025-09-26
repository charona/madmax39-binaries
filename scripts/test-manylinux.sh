# scripts/test-manylinux.sh
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

BIN_NAME="madmax39"   # produced by your build scripts
NET="none"            # always air-gapped

say(){ printf "\n%s\n" "$*"; }

pick_arch() {
  echo "Pick a platform:"
  echo "  1) linux-x64      (manylinux2014, x86_64)"
  echo "  2) linux-aarch64  (manylinux2014, ARM64)"
  read -r -p "Choice [1/2]: " a; a="${a:-1}"
  case "$a" in
    1) ARCH_DIR="dist/linux-x64";     PLATFORM="linux/amd64"    ;;
    2) ARCH_DIR="dist/linux-aarch64"; PLATFORM="linux/arm64/v8" ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
}

pick_image_from_list() {
  echo
  echo "Choose a Docker base image (multi-arch, bash available):"
  echo "  1) debian:bookworm-slim   (modern glibc)"
  echo "  2) debian:bullseye-slim   (older glibc)"
  echo "  3) ubuntu:22.04           (jammy)"
  echo "  4) ubuntu:20.04           (focal)"
  echo "  5) rockylinux:9-minimal   (RHEL9 family)"
  echo "  6) rockylinux:8-minimal   (RHEL8 family)"
  echo "  7) custom…                (type any image name/tag)"
  read -r -p "Choice [1-7]: " ch; ch="${ch:-1}"
  case "$ch" in
    1) IMAGE="debian:bookworm-slim" ;;
    2) IMAGE="debian:bullseye-slim" ;;
    3) IMAGE="ubuntu:22.04" ;;
    4) IMAGE="ubuntu:20.04" ;;
    5) IMAGE="rockylinux:9-minimal" ;;
    6) IMAGE="rockylinux:8-minimal" ;;
    7) read -r -p "Enter image (e.g. registry/name:tag): " IMAGE ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
}

pick_mode() {
  echo
  echo "What do you want to run?"
  echo "  1) --help      (usage only)"
  echo "  2) split       (default mode, no flags)"
  echo "  3) --recover   (recover mode)"
  echo "  4) custom      (enter your own args)"
  read -r -p "Choice [1/2/3/4]: " m; m="${m:-1}"
  case "$m" in
    1) MODE="help" ;;
    2) MODE="split" ;;
    3) MODE="recover" ;;
    4) MODE="custom" ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
  if [[ "$MODE" == "custom" ]]; then
    read -r -p "Enter args to pass after '${BIN_NAME}': " CUSTOM_ARGS
  else
    CUSTOM_ARGS=""
  fi
}

preflight() {
  if [[ ! -x "${ARCH_DIR}/${BIN_NAME}" ]]; then
    echo "❌ ${ARCH_DIR}/${BIN_NAME} not found. Build it first."
    echo "   (e.g. ./scripts/build-linux-x64-manylinux.sh or build-linux-aarch64-manylinux.sh)"
    exit 1
  fi
  command -v docker >/dev/null || { echo "❌ Docker not found/running"; exit 1; }
}

run_info_probe() {
  say "Container environment probe:"
  docker run --rm -t \
    --platform="${PLATFORM}" \
    --network "${NET}" \
    -v "$PWD/${ARCH_DIR}:/app:ro" \
    "${IMAGE}" \
    bash -lc 'set -e; echo -n "Kernel: "; uname -srmo; \
      echo -n "Arch: "; uname -m; \
      (ldd --version 2>/dev/null | head -n1) || echo "ldd not found"; \
      echo -n "Binary perms: "; ls -l /app/'"${BIN_NAME}"' || true'
}

run_interactive() {
  case "$MODE" in
    help)    CMD="/app/${BIN_NAME} --help" ;;
    split)   CMD="/app/${BIN_NAME}" ;;
    recover) CMD="/app/${BIN_NAME} --recover" ;;
    custom)  CMD="/app/${BIN_NAME} ${CUSTOM_ARGS}" ;;
  esac

  say "Running: ${CMD}"
  echo "(air-gapped: --network none)"
  echo
  docker run --rm -it \
    --platform "${PLATFORM}" \
    --network "${NET}" \
    -v "$PWD/${ARCH_DIR}:/app:ro" \
    --tmpfs /work:exec,mode=1777 \
    -w /work \
    "${IMAGE}" \
    bash -lc "${CMD}"
}

# Main
pick_arch
pick_image_from_list
pick_mode
preflight
run_info_probe
run_interactive

