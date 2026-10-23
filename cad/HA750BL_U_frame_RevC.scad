/*
 COMET HA750BL pole-mount Rev.C (2026-10-23).
 Rev.B photo diagnosis: 172mm axial-center spacing was too short to clear finned feed.
 Two independent U-bolted L brackets + adjustable/reprintable connecting strap.
 PETG / Bambu Lab A1 test model. Measured span, feed envelope, mast OD unconfirmed.
 Do not clamp a rotating M-type connector nut; not structurally certified.
 */
part="assembly";
// [assembly,lower_frame,upper_frame,lower_cap,bridge,lower_frame_print,upper_frame_print,lower_cap_print,bridge_print]

// GEOMETRY
pole_diameter=32;                // NOT MEASURED, provisional
lower_fixed_diameter=28;         // approx. nonrotating lower collar OD
upper_element_diameter=16;       // user measurement
support_center_spacing=280;      // provisional, center-to-center along antenna axis
pole_to_antenna_axis=100;        // unchanged Rev.B radial mast clearance
upper_guide_diametric_slack=1.2;
lower_clamp_diametric_slack=0.3;
lower_split_gap=0.8;
pole_cradle_diametric_slack=0.6;
// M6 U-bolts, ONE for each L-bracket
u_bolt_pitch=41;
u_bolt_clearance_d=6.8;
lower_u_z=45;
upper_u_z=65;
// M4 heat inserts in lower clamp (Rev.B-compatible)
insert_pilot_d=5.7;
insert_nominal_length=8.1;
insert_hole_depth=11.4;
lower_clamp_bolt_y=27;
m4_clearance_d=4.5;
m4_head_counterbore_d=8.6;
m4_head_counterbore_depth=3;
// Body
mast_plate_inner_x=12;
mast_plate_thickness=14;
mast_plate_width=78;
lower_arm_height=26;
upper_arm_height=20;
upper_arm_width=65;
upper_arm_front_overhang=29;
lower_cap_front_depth=23;
corner_radius=4;
bracket_spine_height=110;
lower_rib_size=32;
upper_rib_size=32;
rib_width=7;
// Optional linking/strengthening bridge; M5 inserts at mast side ONLY
bridge_thickness=12;
bridge_width=70;
bridge_overlap_each_end=50;
bridge_start_z=60;
bridge_insert_y=25;
bridge_insert_pilot_d=6.7;       // provisional, verify heat-set insert model
bridge_insert_depth=10.3;
bridge_clearance_d=5.5;
bridge_head_pocket_d=10.3;
bridge_head_pocket_depth=3;
bridge_lower_fastener_z=85;
bridge_upper_fastener_local_z=25;
$fn=96;

function plate_front_x()=mast_plate_inner_x+mast_plate_thickness;
function split_back_x()=pole_to_antenna_axis-lower_split_gap/2;
function split_front_x()=pole_to_antenna_axis+lower_split_gap/2;
function upper_global_offset()=support_center_spacing+lower_arm_height/2-(bracket_spine_height-upper_arm_height/2);
function bridge_end_z()=upper_global_offset()+bridge_overlap_each_end;
function bridge_length()=bridge_end_z()-bridge_start_z;
function lower_bolt_on_bridge()=bridge_lower_fastener_z-bridge_start_z;
function upper_bolt_on_bridge()=upper_global_offset()+bridge_upper_fastener_local_z-bridge_start_z;

assert(support_center_spacing>=230 && support_center_spacing<=340,
       "Rev.C bridge spacing supported: 230..340mm (A1 print footprint)");
assert(bridge_length()<=243 && bridge_length()>=120,"Bridge exceeds supported length");
assert(pole_to_antenna_axis>plate_front_x()+lower_fixed_diameter/2+20);
assert(u_bolt_pitch>pole_diameter+5.3,"M6 U-bolt pitch insufficient for mast");
assert(bridge_insert_depth<mast_plate_thickness-1.5);
assert(insert_hole_depth>=insert_nominal_length+1);

module rounded2d(s,r=corner_radius) {
    offset(r=r) square([s[0]-2*r,s[1]-2*r],center=true);
}
module flange(x0,x1,wy,z,thickness) {
    translate([(x0+x1)/2,0,z])
      linear_extrude(height=thickness) rounded2d([x1-x0,wy]);
}
module triangular_rib(points,y0,thickness=rib_width) {
    translate([0,y0+thickness/2,0]) rotate([90,0,0])
      linear_extrude(height=thickness) polygon(points);
}
module pole_saddle(zlo,zhi) {
    translate([0,0,zlo]) cylinder(d=pole_diameter+pole_cradle_diametric_slack,h=zhi-zlo);
}
module two_u_bolt_holes(z) {
    for(y=[-u_bolt_pitch/2,u_bolt_pitch/2])
      translate([mast_plate_inner_x-1,y,z]) rotate([0,90,0])
        cylinder(d=u_bolt_clearance_d,h=mast_plate_thickness+2,$fn=48);
}
module bridge_insert_holes(at_z) {
    for(y=[-bridge_insert_y,bridge_insert_y])
      translate([plate_front_x()-bridge_insert_depth,y,at_z]) rotate([0,90,0])
        cylinder(d=bridge_insert_pilot_d,h=bridge_insert_depth+0.1,$fn=52);
}
module lower_antenna_bore() {
    translate([pole_to_antenna_axis,0,-1])
      cylinder(d=lower_fixed_diameter+lower_clamp_diametric_slack,h=lower_arm_height+2);
}
module lower_insert_holes() {
    for(y=[-lower_clamp_bolt_y,lower_clamp_bolt_y])
      translate([split_back_x()-insert_hole_depth,y,lower_arm_height/2]) rotate([0,90,0])
        cylinder(d=insert_pilot_d,h=insert_hole_depth+1.2,$fn=64);
}
module raw_lower_bracket() {
    union() {
        translate([mast_plate_inner_x,-mast_plate_width/2,0])
          cube([mast_plate_thickness,mast_plate_width,bracket_spine_height]);
        flange(plate_front_x()-1,split_back_x(),mast_plate_width,0,lower_arm_height);
        for(yy=[-31,31])
          triangular_rib([[plate_front_x()-1,lower_arm_height-0.5],
                          [plate_front_x()+lower_rib_size,lower_arm_height-0.5],
                          [plate_front_x()-1,lower_arm_height+lower_rib_size]],yy);
    }
}
module lower_frame() {
    difference() {
        raw_lower_bracket();
        pole_saddle(-1,bracket_spine_height+1);
        two_u_bolt_holes(lower_u_z);
        lower_antenna_bore();
        lower_insert_holes();
        bridge_insert_holes(bridge_lower_fastener_z);
    }
}
module upper_frame() {
    difference() {
        union() {
            translate([mast_plate_inner_x,-mast_plate_width/2,0])
              cube([mast_plate_thickness,mast_plate_width,bracket_spine_height]);
            flange(plate_front_x()-1,pole_to_antenna_axis+upper_arm_front_overhang,
              upper_arm_width,bracket_spine_height-upper_arm_height,upper_arm_height);
            for(yy=[-25,25])
              triangular_rib([[plate_front_x()-1,bracket_spine_height-upper_arm_height+0.5],
                              [plate_front_x()+upper_rib_size,bracket_spine_height-upper_arm_height+0.5],
                              [plate_front_x()-1,bracket_spine_height-upper_arm_height-upper_rib_size]],yy);
        }
        pole_saddle(-1,bracket_spine_height+1);
        two_u_bolt_holes(upper_u_z);
        translate([pole_to_antenna_axis,0,bracket_spine_height-upper_arm_height-1])
          cylinder(d=upper_element_diameter+upper_guide_diametric_slack,h=upper_arm_height+2);
        bridge_insert_holes(bridge_upper_fastener_local_z);
    }
}
module lower_cap() {
    // Rev.B shape preserved; original lower cap STL may be reused.
    difference() {
        flange(split_front_x(),pole_to_antenna_axis+lower_cap_front_depth,
          mast_plate_width,0,lower_arm_height);
        lower_antenna_bore();
        for(y=[-lower_clamp_bolt_y,lower_clamp_bolt_y]) {
            translate([split_front_x()-1,y,lower_arm_height/2]) rotate([0,90,0])
              cylinder(d=m4_clearance_d,h=lower_cap_front_depth+3,$fn=48);
            translate([pole_to_antenna_axis+lower_cap_front_depth-m4_head_counterbore_depth,
              y,lower_arm_height/2]) rotate([0,90,0])
              cylinder(d=m4_head_counterbore_d,h=m4_head_counterbore_depth+1,$fn=48);
        }
    }
}
// Bridge is horizontal when printed: X=length, Y=70, Z=12.
module bridge_print() {
    difference() {
        translate([0,-bridge_width/2,0])
          cube([bridge_length(),bridge_width,bridge_thickness]);
        for(a=[lower_bolt_on_bridge(),upper_bolt_on_bridge()],
            y=[-bridge_insert_y,bridge_insert_y]) {
            translate([a,y,-0.5])
              cylinder(d=bridge_clearance_d,h=bridge_thickness+1,$fn=48);
            // HEAD POCKET is outside (+global X), corresponding to local Z=0
            translate([a,y,-0.1])
              cylinder(d=bridge_head_pocket_d,h=bridge_head_pocket_depth+0.1,$fn=48);
        }
    }
}
module bridge_assembly() {
    translate([plate_front_x()+bridge_thickness,0,bridge_start_z])
      rotate([0,-90,0]) bridge_print();
}
module lower_frame_print() {
    translate([0,bracket_spine_height,mast_plate_width/2])
      rotate([90,0,0]) lower_frame();
}
module upper_frame_print() {
    translate([0,bracket_spine_height,mast_plate_width/2])
      rotate([90,0,0]) upper_frame();
}
module preview_pole() {
    color([.60,.62,.65,.5]) translate([0,0,-28])
      cylinder(d=pole_diameter,h=upper_global_offset()+bracket_spine_height+56);
}
module preview_antenna() {
    // NOT a dimensional model of the actual feed; illustrative cylinders only
    color([.75,.67,.47]) translate([pole_to_antenna_axis,0,-20])
      cylinder(d=lower_fixed_diameter,h=70);
    color([.70,.72,.74]) translate([pole_to_antenna_axis,0,50])
      cylinder(d=66,h=195);
    color([.75,.67,.47]) translate([pole_to_antenna_axis,0,235])
      cylinder(d=upper_element_diameter,h=support_center_spacing+125-235);
}
module assembly() {
    preview_pole(); preview_antenna();
    color([.16,.45,.66]) lower_frame();
    color([.18,.60,.47]) translate([0,0,upper_global_offset()]) upper_frame();
    color([.14,.67,.50]) lower_cap();
    color([.93,.53,.18]) bridge_assembly();
}
if(part=="lower_frame") lower_frame();
else if(part=="upper_frame") upper_frame();
else if(part=="lower_cap" || part=="lower_cap_print") lower_cap();
else if(part=="bridge" || part=="bridge_print") bridge_print();
else if(part=="lower_frame_print") lower_frame_print();
else if(part=="upper_frame_print") upper_frame_print();
else assembly();
