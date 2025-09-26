#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

docker run --rm -t \
  --platform=linux/arm64/v8 \
  -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
  -v "$PWD":/io -w /io \
  quay.io/pypa/manylinux2014_aarch64 /bin/bash -lc '
    set -euo pipefail

    # Toolchain & headers (include libffi-devel for _ctypes)
    yum -y install \
      gcc make perl-core wget tar \
      zlib-devel bzip2-devel xz-devel \
      libffi-devel readline-devel sqlite-devel

    # OpenSSL
    cd /tmp && wget -q https://www.openssl.org/source/openssl-1.1.1w.tar.gz && tar xf openssl-1.1.1w.tar.gz
    cd openssl-1.1.1w
    ./config --prefix=/opt/openssl --libdir=lib shared zlib
    make -j"$(nproc)" && make install_sw

    # Python 3.11 with shared lib, OpenSSL, and **system libffi**
    cd /tmp && wget -q https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz && tar xf Python-3.11.9.tgz
    cd Python-3.11.9
    ./configure \
      --prefix=/opt/python/cp311-shared \
      --enable-optimizations \
      --enable-shared \
      --with-system-ffi \
      --with-openssl=/opt/openssl \
      LDFLAGS="-Wl,-rpath=/opt/python/cp311-shared/lib:/opt/openssl/lib"
    make -j"$(nproc)" && make install

    export PATH=/opt/python/cp311-shared/bin:$PATH
    export LD_LIBRARY_PATH=/opt/openssl/lib:/opt/python/cp311-shared/lib:$LD_LIBRARY_PATH

    # Pip + deps
    python3.11 -m ensurepip
    python3.11 -m pip install -U pip
    pip install pyinstaller shamir-mnemonic "cryptography<43" mnemonic

    # Sanity: _ctypes present
    python3.11 - <<PY
import ctypes, _ctypes
print("ctypes OK")
PY

    # Build
    cd /io
    rm -rf build dist/linux-aarch64
    pyinstaller madmax39.spec --distpath dist/linux-aarch64
    chown -R "$HOST_UID:$HOST_GID" dist
  '
echo "✅ Built dist/linux-aarch64/madmax39"

