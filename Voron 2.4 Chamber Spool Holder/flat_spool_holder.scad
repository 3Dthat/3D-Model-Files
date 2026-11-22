// Voron 2.4 350 in-chamber spool holder, FLAT version: the spool lies on its side (axis vertical) tucked right up
// under the top panel, so it only takes ~75 mm of height below the top rail instead of ~215 mm.
// An arm bolts to a top 2020 rail and runs out under the top panel at rail height. A hub "carrier" (tube + bottom
// flange the spool sits on) hangs from the arm end by a cone head that slides into a slot from the front.
// The head drops into a 1 mm deep seat so it can't walk out. The head turns in its seat, so the spool can unwind.
// Swap spools: lift the carrier ~1 mm, slide it forward out of the arm, pull the spool off the top of the tube.
//
// Coords (assembly): X along the rail, Y into the chamber (rail inner face at Y=0), Z up (rail bottom Z=0,
// rail top / underside of top panel Z=20).
//
// Parts: "arm" (print 1, on its side as exported), "carrier" (print 1, flange down as exported), "assembly"
// Hardware: 2x M5x10 + 2x drop-in/roll-in T-nuts into the rail's BOTTOM slot. A key also sits in the inner-face
//   slot (trim it off if an LED strip lives there).
// Print: ABS/ASA (chamber 50-65 C), 5 walls, 40% infill, no supports.
// Mount it toward a front corner, away from the umbilical / cable path at the back.

part = "assembly";
show_panel = true;

/* ---- spool ---- */
spool_d = 200;  spool_w = 70;  hub_d = 52;     // standard 1 kg spool; hub_d = smallest hub you use
clear   = 12;                                 // spool rim to rail face (root block is 10 deep)

/* ---- rail ---- */
ext = 20;
top_gap  = 0.5;                  // arm top sits this far under the top panel (foam tape etc.)
m5_clear = 5.5; m5_head_d = 10; under_head = 5;
key_w = 5.8; key_h = 1.5;

/* ---- arm ---- */
arm_t   = 14;                    // vertical thickness of the arm (Z)
arm_w   = 54;                    // width of the arm (X)
ledge_t = 6;                     // plate under the rail
bolt_dx = 34;                    // spacing of the two bottom-slot bolts

/* ---- carrier ---- */
tube_d   = hub_d - 4;            // 48: spool hub slides over with play
tube_id  = tube_d - 12;
flange_d = 100;  flange_t = 4;   // spool sits on this (flange well inside the filament, under the spool's side)
neck_d   = 20;
head_d   = 34;  head_h = 1.5;     // straight part of the head above its 45 deg cone
seat_drop = 1;                   // head drops into the seat this much
hang_gap = 2;                    // arm bottom to tube top
c = 0.4;                         // slot clearance per side

/* ---- derived ---- */
arm_top = ext - top_gap;
arm_bot = arm_top - arm_t;
cone_h  = (head_d - neck_d) / 2;
axis_y  = clear + spool_d/2;                         // spool / carrier axis
arm_len = axis_y + head_d/2 + 8;
seat_z  = arm_bot + 4;                               // where the cone starts (bottom ledge 4 mm under the cone)
tube_top = arm_bot - hang_gap;
tube_len = spool_w + 3;
spool_top = tube_top - 3;
drop = -(spool_top - spool_w - flange_t);

echo(str("Spool axis ", axis_y, " mm in front of the rail. Spool top ", spool_top, " mm, bottom of carrier ",
         -drop, " mm (relative to rail bottom). Takes ", drop, " mm of height below the rail."));

$fn = 72;

// slot profile in XZ (cut along Y): neck slot, 45 deg cone, head pocket open to the top
module slot_profile(dz = 0) {
  w0 = neck_d/2 + c; w1 = head_d/2 + c; z0 = seat_z + dz;
  polygon([[-w0, arm_bot - 1], [w0, arm_bot - 1], [w0, z0], [w1, z0 + (w1 - w0)], [w1, arm_top + 1],
           [-w1, arm_top + 1], [-w1, z0 + (w1 - w0)], [-w0, z0]]);
}

module arm() {
  difference() {
    union() {
      // arm under the top panel, from the rail face to past the spool axis
      hull() {
        translate([-arm_w/2, 0, arm_bot]) cube([arm_w, 1, arm_t]);
        translate([0, axis_y, arm_bot]) cylinder(d = head_d + 16, h = arm_t);
      }
      // root block against the rail face + ledge under the rail
      translate([-arm_w/2, 0, -ledge_t]) cube([arm_w, 10, arm_top + ledge_t]);
      translate([-arm_w/2, -ext + 1, -ledge_t]) cube([arm_w, ext - 1 + 10, ledge_t]);
      // slot keys
      translate([-arm_w/2, -ext/2 - key_w/2, -0.01]) cube([arm_w, key_w, key_h]);
      translate([-arm_w/2, -key_h, ext/2 - key_w/2]) cube([arm_w, key_h + 0.01, key_w]);
    }
    // entry slot from the front edge, 1 mm higher than the seat
    translate([0, axis_y, 0]) mirror([0, 1, 0]) rotate([90, 0, 0]) linear_extrude(arm_len) slot_profile(seat_drop);
    // seat (round, 1 mm lower) - rotate_extrude of the same profile
    translate([0, axis_y, 0]) rotate_extrude() intersection() { slot_profile(0); translate([0, -50]) square(100); }
    // 2x M5 up into the bottom slot
    for (x = [-bolt_dx/2, bolt_dx/2]) translate([x, -ext/2, 0]) rotate([180, 0, 0]) {
      translate([0, 0, -5]) cylinder(d = m5_clear, h = ledge_t + 10);
      translate([0, 0, under_head]) cylinder(d = m5_head_d, h = 30);
    }
  }
}

// carrier in assembly position (head seated), axis at origin XY
module carrier() {
  z_cone = seat_z;                          // cone bottom (seated)
  difference() {
    union() {
      translate([0, 0, tube_top - tube_len]) cylinder(d = tube_d, h = tube_len);
      translate([0, 0, tube_top - tube_len - flange_t]) cylinder(d = flange_d, h = flange_t);
      // chamfer between flange and tube (strength)
      translate([0, 0, tube_top - tube_len]) cylinder(d1 = tube_d + 8, d2 = tube_d, h = 4);
      translate([0, 0, tube_top - 0.01]) cylinder(d = neck_d, h = z_cone - tube_top + 0.02);
      translate([0, 0, z_cone]) cylinder(d1 = neck_d, d2 = head_d, h = cone_h);
      translate([0, 0, z_cone + cone_h]) cylinder(d = head_d, h = head_h);
    }
    translate([0, 0, tube_top - tube_len + 2]) cylinder(d = tube_id, h = tube_len - 6);   // 4 mm cap under the neck
    // lead-in chamfer at the tube top so the spool slides on
    translate([0, 0, tube_top - 3]) difference() { cylinder(d = tube_d + 1, h = 4); cylinder(d1 = tube_d, d2 = tube_d - 6, h = 3); }
    // lightening holes in the flange
    for (a = [0:60:359]) rotate(a) translate([(tube_d/2 + flange_d/2)/2 + 2, 0, tube_top - tube_len - flange_t - 1])
      cylinder(d = 14, h = flange_t + 2);
  }
}

module rail_mock(len = 300) {
  color("dimgray") difference() {
    translate([-len/2, -ext, 0]) cube([len, ext, ext]);
    for (a = [[-ext/2, ext - 3], [-3, ext/2], [-ext/2, 3], [-ext + 3, ext/2]])
      translate([-len/2 - 1, a[0] - 3, a[1] - 3]) cube([len + 2, 6, 6]);
  }
}

module spool_mock() {
  color("orange", 0.75) translate([0, 0, spool_top - spool_w]) difference() {
    union() {
      cylinder(d = spool_d, h = 3);
      translate([0, 0, spool_w - 3]) cylinder(d = spool_d, h = 3);
      cylinder(d = spool_d - 40, h = spool_w);
    }
    translate([0, 0, -1]) cylinder(d = hub_d, h = spool_w + 2);
  }
}

module panel_mock() { color("lightblue", 0.25) translate([-160, -ext, ext]) cube([320, 240, 3]); }

module assembly() {
  rail_mock();
  if (show_panel) panel_mock();
  color("steelblue") arm();
  color("lightsteelblue") translate([0, axis_y, 0]) carrier();
  translate([0, axis_y, 0]) spool_mock();
}

if (part == "arm") rotate([0, -90, 0]) translate([arm_w/2, 0, 0]) arm();     // on its side: no supports
else if (part == "carrier") translate([0, 0, -(tube_top - tube_len - flange_t)]) carrier();
else if (part == "section") difference() { assembly(); translate([0, -100, -200]) cube([400, 600, 400]); }
else assembly();
