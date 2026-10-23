#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
mkdir -p stl images
for p in lower_frame_print upper_frame_print lower_cap_print bridge_print; do
  openscad -o "stl/HA750BL_RevC_${p}.stl" -D "part=\"$p\"" cad/HA750BL_U_frame_RevC.scad
done
xvfb-run -a openscad -o images/HA750BL_RevC_assembly.png \
  --imgsize=1280,900 --colorscheme=Tomorrow --viewall --autocenter \
  --camera=0,0,0,67,0,40,600 -D 'part="assembly"' cad/HA750BL_U_frame_RevC.scad
python tools/validate_revC.py
