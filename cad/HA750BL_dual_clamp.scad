/*
  COMET HA750BL pole mount, dual split bridge-clamp prototypes.
  Rev.A / 2026-10-21. Parametric OpenSCAD.
  Section 1: lower fixed 28-mm section. Section 2: upper 16-mm guide.
  This prototype is NOT rated for wind-loading or permanent outdoor use.
  Critical: do NOT clamp a rotating PL-259 connector coupling ring.
*/

// =============== CUSTOMIZE ===============
part = "assembly"; // [assembly,lower_base,lower_cap,upper_base,upper_cap]
pole_diameter = 32;            // Mast outside diameter (mm), UPDATE after measurement
lower_antenna_diameter = 28;   // User's approximate lower section outside diameter
upper_element_diameter = 16;   // User's upper element outside diameter
center_spacing = 88;          // Antenna/mast center to center (mm); feed-body clearance TBD
upper_position = 180;         // For preview only: arbitrary spacing (mm)

mast_diametric_clearance = 0.25;
lower_diametric_clearance = 0.25;
upper_diametric_clearance = 1.20; // Loose guide, not structural clamp
print_orientation = false;      // false: flat Z=0 face rests on bed; recommended for PETG
split_gap = 1.20;                // Initial mating gap between halves
shell_wall = 7.0;
bolt_diameter = 5.5;            // M5 pass-through, 0.5-mm clearance
nut_corner_diameter = 9.5;      // M5 hexagonal nut trap, check your nut AF
head_diameter = 10.0;           // M5 socket cap head counterbore

lower_height = 22;             // Contact height, must fit available straight section
upper_height = 18;
$fn=96;

// =============== CAD ===============
function antenna_d(which) = which=="lower" ? lower_antenna_diameter : upper_element_diameter;
function antenna_clearance(which) = which=="lower" ? lower_diametric_clearance : upper_diametric_clearance;
function clamp_height(which) = which=="lower" ? lower_height : upper_height;
function mast_r() = (pole_diameter + mast_diametric_clearance)/2;
function antenna_r(which) = (antenna_d(which)+antenna_clearance(which))/2;
function left_bolt_x() = -mast_r() - shell_wall - 7;
function mid_bolt_x() = center_spacing/2;
function right_bolt_x(which) = center_spacing + antenna_r(which) + shell_wall + 7;

module outline2d(which) {
    union() {
        circle(r=mast_r()+shell_wall);
        translate([center_spacing,0]) circle(r=antenna_r(which)+shell_wall);
        hull() {
            circle(r=10);
            translate([center_spacing,0]) circle(r=10);
        }
        hull() {
            circle(r=mast_r()+shell_wall);
            translate([left_bolt_x(),0]) circle(r=9.5);
        }
        hull() {
            translate([center_spacing,0]) circle(r=antenna_r(which)+shell_wall);
            translate([right_bolt_x(which),0]) circle(r=9.5);
        }
    }
}
module section2d(which) {
    difference() {
        outline2d(which);
        circle(r=mast_r());
        translate([center_spacing,0]) circle(r=antenna_r(which));
    }
}

module clamp_piece(which,side) {
    h=clamp_height(which);
    xbolts=[left_bolt_x(), mid_bolt_x(), right_bolt_x(which)];
    difference() {
        intersection() {
            linear_extrude(height=h) section2d(which);
            if(side=="base")
                translate([-250,-250,-1]) cube([500,250-split_gap/2,h+2]);
            else
                translate([-250,split_gap/2,-1]) cube([500,250,h+2]);
        }
        for(x=xbolts) {
            // M5 bolt axis is in the Y direction, perpendicular to the split plane.
            translate([x,0,h/2]) rotate([90,0,0]) cylinder(d=bolt_diameter,h=120,center=true,$fn=48);
            if(side=="base") {
                // Back-side hex pocket; normal M5 nut (AF 8 mm)
                translate([x,-9,h/2]) rotate([90,0,0]) cylinder(d=nut_corner_diameter,h=8,center=true,$fn=6);
            } else {
                // Front-side socket head recess
                translate([x,9,h/2]) rotate([90,0,0]) cylinder(d=head_diameter,h=7,center=true,$fn=48);
            }
        }
    }
}
module preview_tube(x,d,z,h,c) {
    color(c) translate([x,0,z]) cylinder(d=d,h=h,$fn=72);
}
module assembly() {
    // Pole + mounting areas are only dimensional reference objects,
    // NOT included in exported printable part STLs.
    preview_tube(0,pole_diameter,-25,upper_position+75,[0.48,0.52,0.58,0.48]);
    preview_tube(center_spacing,lower_antenna_diameter,-10,52,[0.90,0.65,0.15,0.55]);
    preview_tube(center_spacing,55,42,105,[0.10,0.10,0.12,0.38]); // Illustrative finned body (unverified diameter)
    preview_tube(center_spacing,upper_element_diameter,147,upper_position+45-147,[0.90,0.65,0.15,0.55]);
    for (which=["lower","upper"]) {
        z = which=="lower" ? 0 : upper_position;
        color(which=="lower" ? [0.12,0.31,0.60] : [0.16,0.55,0.40])
            translate([0,0,z]) clamp_piece(which,"base");
        color(which=="lower" ? [0.21,0.47,0.78] : [0.27,0.72,0.48])
            translate([0,0,z]) clamp_piece(which,"cap");
    }
}

module printable_piece(which,side) {
    if(print_orientation) {
        if(side=="base") translate([0,0,-split_gap/2]) rotate([-90,0,0]) clamp_piece(which,side);
        else translate([0,0,-split_gap/2]) rotate([90,0,0]) clamp_piece(which,side);
    } else clamp_piece(which,side);
}

if(part=="lower_base") printable_piece("lower","base");
else if(part=="lower_cap") printable_piece("lower","cap");
else if(part=="upper_base") printable_piece("upper","base");
else if(part=="upper_cap") printable_piece("upper","cap");
else assembly();
