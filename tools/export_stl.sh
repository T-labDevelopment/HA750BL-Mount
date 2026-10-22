#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$root/stl"
POLE="${1:-32}"
for part in lower_base lower_cap upper_base upper_cap; do
  openscad --export-format binstl -o "$root/stl/${part}_pole${POLE}.stl" \
    -D "part=\"$part\"" \
    -D "pole_diameter=$POLE" \
    "$root/cad/HA750BL_dual_clamp.scad"
done
