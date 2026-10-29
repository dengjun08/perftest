#!/usr/bin/env bash
# Smoke-test the dev environment without InfiniBand hardware.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

bins=(
  ib_send_bw ib_send_lat ib_write_bw ib_write_lat
  ib_read_bw ib_read_lat ib_atomic_bw ib_atomic_lat
)

for bin in "${bins[@]}"; do
  if [[ ! -x "$root/$bin" ]]; then
    echo "missing executable: $bin" >&2
    exit 1
  fi
  if ! { "$root/$bin" -V 2>&1 || true; } | grep -q Version; then
    echo "version check failed: $bin" >&2
    exit 1
  fi
done

msg=$("$root/ib_write_bw" 2>&1 || true)
if ! grep -q 'Unable to find the Infiniband/RoCE device' <<<"$msg"; then
  echo "unexpected ib_write_bw output (expected missing-device message):" >&2
  echo "$msg" >&2
  exit 1
fi

echo "perftest dev environment OK (${#bins[@]} benchmarks built; RDMA user-space libraries linked)"
