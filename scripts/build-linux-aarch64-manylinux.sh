#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

docker run --rm -t \
  --platform=linux/arm64/v8 \
  -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
  -v "$PWD":/io -w /io \
  quay.io/pypa/manylinux2014_aarch64 /bin/bash -lc '
    set -euo pipefail
    yum -y install gcc make perl-core wget tar zlib-devel bzip2-devel xz-devel libffi-devel readline-devel sqlite-devel
    cd /tmp && wget -q https://www.openssl.org/source/openssl-1.1.1w.tar.gz && tar xf openssl-1.1.1w.tar.gz
    cd openssl-1.1.1w && ./config --prefix=/opt/openssl --libdir=lib shared zlib && make -j"$(nproc)" && make install_sw
    cd /tmp && wget -q https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz && tar xf Python-3.11.9.tgz
    cd Python-3.11.9 && ./configure --prefix=/opt/python/cp311-shared --enable-optimizations --enable-shared --with-openssl=/opt/openssl LDFLAGS="-Wl,-rpath=/opt/python/cp311-shared/lib:/opt/openssl/lib"
    make -j"$(nproc)" && make install
    export PATH=/opt/python/cp311-shared/bin:$PATH
    export LD_LIBRARY_PATH=/opt/openssl/lib:/opt/python/cp311-shared/lib:$LD_LIBRARY_PATH
    python3.11 -m ensurepip && python3.11 -m pip install -U pip
    pip install pyinstaller shamir-mnemonic "cryptography<43" mnemonic
    cd /io
    rm -rf build dist/linux-aarch64
    pyinstaller madmax39.spec --distpath dist/linux-aarch64 --name madmax39
    chown -R "$HOST_UID:$HOST_GID" dist
  '
echo "✅ Built dist/linux-aarch64/madmax39"

