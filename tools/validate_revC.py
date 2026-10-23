#!/usr/bin/env python3
"""Mesh closure and Bambu Lab A1 256mm envelope, NOT strength tests."""
from pathlib import Path
import trimesh

root = Path(__file__).resolve().parent.parent
for part in ('lower_frame_print','upper_frame_print','lower_cap_print','bridge_print'):
    path = root/'stl'/f'HA750BL_RevC_{part}.stl'
    mesh = trimesh.load_mesh(path)
    dims = mesh.extents
    assert mesh.is_watertight and len(mesh.split())==1 and mesh.volume>0, f'{path.name}: invalid mesh'
    assert (dims<=256).all(), f'{path.name}: exceeds A1 256mm envelope: {dims}'
    print(f'PASS {path.name}: one watertight solid, dims={dims.round(1)}, volume={mesh.volume:.1f} mm^3')
print('This does not certify outdoor loads, prints, dimensional fit or SWR.')
