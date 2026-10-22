/*
  COMET HA750BL antenna pole bracket — Rev.B (2026-10-21)
  Parametric one-piece C/U frame + separate lower clamp jaw.
  A pair of M6 extended-leg U-bolts fixes the frame to the mast.
  Upper element is ONLY guided by a smooth through-bore, no metal near the hole.
  Lower fixed 28-mm section is clamped by two M4 screws and heat-set inserts.

  NOT STRUCTURALLY CERTIFIED for exterior mounting / antenna wind loads.
  Do not clamp a rotating coax connector coupling nut.
  Units: mm. Source-of-truth design, use export script to regenerate meshes.
*/

part = "assembly"; // [assembly,frame,lower_cap,frame_print,lower_cap_print]

// ---- USER / FIELD MEASUREMENTS ----
pole_diameter = 32;                 // provisional actual mast OD
upper_diameter = 16;                // supplied element OD
lower_diameter = 28;                // approximate OD; verify fixed cylindrical section
antenna_axis_x = 100;              // horizontal c-c from mast, check feed radial clearance
upper_guide_bottom_z = 175;        // flange elevation; lower flange bottom is Z=0

// ---- PRINT FIT ----
upper_bore_extra_d = 1.2;           // Ø17.2 smooth clearance, NO compression
lower_bore_extra_d = 0.3;           // Ø28.3 before print shrink compensation
lower_split_gap = 0.8;             // intentional gap between the two jaw faces
mast_saddle_extra_d = 0.6;         // pole cradle clearance

// ---- U BOLT (CANDIDATE: M6, 25A extended-leg +10) ----
u_bolt_pitch = 41;                  // center-to-center leg pitch; M6 25A nominal example
u_bolt_rod_d = 6;                   // actual U-bolt stud diameter
u_bolt_clearance_d = 6.8;          // printed holes
u_bolt_z_positions = [49,139];    // two vertically spaced pairs

// ---- M4 HEAT-SET INSERTS / SCREWS ----
insert_pilot_d = 5.7;              // CNC Kitchen M4x8.1 recommendation; verify purchased item
insert_nominal_length = 8.1;
insert_hole_depth = 11.4;          // >= insert length + 1mm
m4_clearance_d = 4.5;
m4_head_counterbore_d = 8.6;
m4_head_counterbore_depth = 3.0;
lower_clamp_bolt_y = 27;           // +/- offset to avoid the antenna bore

// ---- FRAME ----
mast_plate_inner_x = 12;
mast_plate_thickness = 14;
mast_plate_width = 78;             // Y direction; +/-39
lower_arm_thickness = 26;
upper_arm_thickness = 20;
upper_arm_width = 65;
upper_arm_front_overhang = 29;
lower_cap_front_depth = 23.0;      // front face x = antenna_axis_x+23
corner_radius = 4.0;
gusset_length = 33;
gusset_height = 33;
gusset_thickness = 7;
$fn=96;

function frame_height() = upper_guide_bottom_z + upper_arm_thickness;
function plate_front_x() = mast_plate_inner_x + mast_plate_thickness;
function split_back_x() = antenna_axis_x - lower_split_gap/2;
function split_front_x() = antenna_axis_x + lower_split_gap/2;

assert(u_bolt_pitch > pole_diameter + u_bolt_rod_d - 1, "U-bolt leg pitch too small for pole");
assert(upper_guide_bottom_z > 2 * lower_arm_thickness + 20, "Top arm overlaps lower area");
assert(antenna_axis_x > plate_front_x() + lower_diameter/2 + 20, "Insufficient antenna-axis clearance");
assert(insert_hole_depth >= insert_nominal_length+1, "Insufficient heat-set insert hole depth");

module rounded_rect2d(size_xy, radius=3) {
    offset(r=radius) square([size_xy[0]-2*radius, size_xy[1]-2*radius], center=true);
}
module rectangular_flange(x0,x1,ywidth,zbase,thickness,round_r=4) {
    translate([(x0+x1)/2,0,zbase])
        linear_extrude(height=thickness)
            rounded_rect2d([x1-x0,ywidth],round_r);
}
module triangular_gusset(triangle_xz, at_y, width) {
    translate([0,at_y+width/2,0]) rotate([90,0,0])
        linear_extrude(height=width) polygon(points=triangle_xz);
}
module uncut_frame() {
    union() {
        // Single rigid spine near the mounting pole
        translate([mast_plate_inner_x,-mast_plate_width/2,0])
            cube([mast_plate_thickness,mast_plate_width,frame_height()]);
        // Lower support ending at rear half of removable lower clamp
        rectangular_flange(plate_front_x()-1,split_back_x(),
                            mast_plate_width,0,lower_arm_thickness,corner_radius);
        // Upper guide: purely plastic pass-through opening, no split/nuts
        rectangular_flange(plate_front_x()-1,
                            antenna_axis_x+upper_arm_front_overhang,
                            upper_arm_width,upper_guide_bottom_z,
                            upper_arm_thickness,corner_radius);
        // 4 gussets at each side of upper and lower transitions
        for(yy=[-31,31]) {
            triangular_gusset([[plate_front_x()-1,lower_arm_thickness-0.5],
                               [plate_front_x()+gusset_length,lower_arm_thickness-0.5],
                               [plate_front_x()-1,lower_arm_thickness+gusset_height]],
                               yy,gusset_thickness);
        }
        for(yy=[-25,25]) {
            triangular_gusset([[plate_front_x()-1,upper_guide_bottom_z+0.5],
                               [plate_front_x()+gusset_length,upper_guide_bottom_z+0.5],
                               [plate_front_x()-1,upper_guide_bottom_z-gusset_height]],
                               yy,gusset_thickness);
        }
    }
}
module lower_antenna_bore() {
    translate([antenna_axis_x,0,-1])
        cylinder(d=lower_diameter+lower_bore_extra_d,
                 h=lower_arm_thickness+2);
}
module upper_antenna_bore() {
    translate([antenna_axis_x,0,upper_guide_bottom_z-1])
        cylinder(d=upper_diameter+upper_bore_extra_d,
                 h=upper_arm_thickness+2);
}
module pole_saddle() {
    translate([0,0,-1]) cylinder(d=pole_diameter+mast_saddle_extra_d,
                                  h=frame_height()+2);
}
module u_bolt_holes() {
    for(z=u_bolt_z_positions, y=[-u_bolt_pitch/2,u_bolt_pitch/2]) {
        translate([mast_plate_inner_x-1,y,z]) rotate([0,90,0])
            cylinder(d=u_bolt_clearance_d,h=mast_plate_thickness+2,$fn=48);
    }
}
module heat_insert_holes() {
    for(y=[-lower_clamp_bolt_y, lower_clamp_bolt_y]) {
        // blind holes inserted from the split face, directed toward the mast
        translate([split_back_x()-insert_hole_depth,y,lower_arm_thickness/2])
            rotate([0,90,0]) cylinder(d=insert_pilot_d,h=insert_hole_depth+1.2,$fn=64);
    }
}
module main_frame() {
    difference() {
        uncut_frame();
        pole_saddle();
        u_bolt_holes();
        lower_antenna_bore();
        upper_antenna_bore();
        heat_insert_holes();
    }
}
module uncut_lower_cap() {
    rectangular_flange(split_front_x(),antenna_axis_x+lower_cap_front_depth,
                         mast_plate_width,0,lower_arm_thickness,corner_radius);
}
module lower_cap() {
    difference() {
        uncut_lower_cap();
        lower_antenna_bore();
        for(y=[-lower_clamp_bolt_y, lower_clamp_bolt_y]) {
            // M4 clearance extends fully through front jaw along X
            translate([split_front_x()-1,y,lower_arm_thickness/2])
                rotate([0,90,0]) cylinder(d=m4_clearance_d,
                                           h=lower_cap_front_depth+3,$fn=48);
            // Button/socket head pocket on the outward (+X) face
            translate([antenna_axis_x+lower_cap_front_depth-m4_head_counterbore_depth,
                       y,lower_arm_thickness/2])
                rotate([0,90,0]) cylinder(d=m4_head_counterbore_d,
                                           h=m4_head_counterbore_depth+1,$fn=48);
        }
    }
}

// ================ NONPRINTED MOCKUPS ================
module preview_pole() {
    color([0.62,0.66,0.71,0.35]) translate([0,0,-20])
        cylinder(d=pole_diameter,h=frame_height()+45);
}
module preview_antenna() {
    color([0.87,0.65,0.17,0.58])
        translate([antenna_axis_x,0,-14]) cylinder(d=lower_diameter,h=lower_arm_thickness+50);
    // feed body ONLY a schematic silhouette; DO NOT use as a dimension source
    color([0.2,0.24,0.30,0.22])
        translate([antenna_axis_x,0,lower_arm_thickness+48]) cylinder(d=43,h=59);
    color([0.88,0.63,0.16,0.55])
        translate([antenna_axis_x,0,upper_guide_bottom_z-26])
            cylinder(d=upper_diameter,h=upper_arm_thickness+61);
}
module preview_heat_inserts() {
    for(y=[-lower_clamp_bolt_y,lower_clamp_bolt_y]) {
        color([0.95,0.60,0.10])
            translate([split_back_x()-insert_nominal_length,y,lower_arm_thickness/2])
                rotate([0,90,0]) difference() {
                    cylinder(d=6.3,h=insert_nominal_length);
                    translate([0,0,-0.5]) cylinder(d=4,h=insert_nominal_length+1);
                }
    }
}
module preview_u_bolts() {
    // approximate drawing only; actual U-bolt lengths and bent radius differ by part
    for(z=u_bolt_z_positions) {
        color([0.62,0.66,0.73]) {
            for(y=[-u_bolt_pitch/2,u_bolt_pitch/2]) {
                translate([0,y,z]) rotate([0,90,0]) cylinder(d=u_bolt_rod_d,h=41,$fn=36);
                translate([plate_front_x()+2,y,z]) rotate([0,90,0])
                    cylinder(d=10,h=5,$fn=6);
            }
            // a curved U-bolt around back of pole, modelled via tube along semicircle
            for(a=[0:8:172]) {
                yy1=(u_bolt_pitch/2)*cos(a);
                xx1=-(u_bolt_pitch/2)*sin(a);
                yy2=(u_bolt_pitch/2)*cos(a+8);
                xx2=-(u_bolt_pitch/2)*sin(a+8);
                hull() {
                    translate([xx1,yy1,z]) sphere(d=u_bolt_rod_d,$fn=18);
                    translate([xx2,yy2,z]) sphere(d=u_bolt_rod_d,$fn=18);
                }
            }
        }
    }
}
module assembly() {
    preview_pole();
    preview_antenna();
    color([0.18,0.48,0.65]) main_frame();
    color([0.12,0.67,0.54]) lower_cap();
    preview_heat_inserts();
    preview_u_bolts();
}

module frame_print() {
    // Print on one side: footprint about 130 x 195 mm, height 78 mm.
    // Print supports/bridge tuning may be needed for transverse bores.
    translate([0,frame_height(),mast_plate_width/2])
        rotate([90,0,0]) main_frame();
}

if(part=="frame") main_frame();
else if(part=="lower_cap") lower_cap();
else if(part=="frame_print") frame_print();
else if(part=="lower_cap_print") lower_cap();
else assembly();
