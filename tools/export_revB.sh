#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cad="$root/cad/HA750BL_U_frame_RevB.scad"
mkdir -p "$root/stl" "$root/images"
for part in frame lower_cap frame_print lower_cap_print; do
  echo "Exporting Rev.B $part..."
  openscad -o "$root/stl/HA750BL_RevB_${part}.stl" -D "part=\"$part\"" "$cad"
done
xvfb-run -a openscad -o "$root/images/HA750BL_RevB_assembly.png" \
  --imgsize=1280,960 --colorscheme=Tomorrow --viewall --autocenter \
  --camera=0,0,0,67,0,40,540 \
  -D 'part="assembly"' "$cad"
