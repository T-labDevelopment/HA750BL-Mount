#!/usr/bin/env python3
"""Check Rev.B STL meshes and physical print-envelope, not mechanical strength."""
from pathlib import Path
import trimesh

root=Path(__file__).resolve().parent.parent
mesh_paths=[root/'stl'/f'HA750BL_RevB_{part}.stl' for part in (
    'frame','lower_cap','frame_print','lower_cap_print')]
for path in mesh_paths:
    mesh=trimesh.load_mesh(path)
    if not mesh.is_watertight or len(mesh.split())!=1 or mesh.volume<=0:
        raise RuntimeError(f'{path.name}: mesh integrity check failed')
    dims=mesh.extents
    if 'print' in path.stem and max(dims)>256:
        raise RuntimeError(f'{path.name}: outside Bambu Lab A1 256mm envelope')
    print(f'PASS {path.name}: watertight, one solid; extents {dims.round(2).tolist()} mm')
print('PASS: static mesh/envelope checks; no strength or real-world fit certification')
