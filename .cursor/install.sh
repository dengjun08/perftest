#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq \
  autoconf \
  automake \
  gcc \
  ibverbs-utils \
  libibumad-dev \
  libibverbs-dev \
  libpci-dev \
  librdmacm-dev \
  libtool \
  make \
  rdma-core

if [[ ! -f configure ]]; then
  ./autogen.sh
fi

if [[ ! -f Makefile ]] || [[ configure.ac -nt Makefile ]]; then
  ./configure --prefix="${PWD}/install"
fi

make -j"$(nproc)"
make install
