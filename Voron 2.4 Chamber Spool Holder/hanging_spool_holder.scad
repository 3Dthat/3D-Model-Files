// Voron 2.4 350 in-chamber spool holder: hangs a filament spool from a TOP 2020 frame rail so chamber
// heat dries it. Two identical hanger arms bolt to the rail (L clamp: inner face + bottom face), a drop-in
// axle sits in open hook slots at the bottom, the spool rides on the axle. Lift the axle out to swap spools.
//
// Coords (assembly): X along the rail, Y into the chamber (rail inner face at Y=0), Z up (rail bottom at Z=0).
//
// Parts: "arm" (print 2, lying flat as exported), "axle" (print 1, standing up as exported), "assembly" (preview)
// Hardware per arm: 2x M5x10 SHCS/BHCS + 2x M5 drop-in/roll-in T-nuts (one in the rail's inner-face slot,
//   one in the bottom slot). Either bolt alone holds a 1 kg spool; use both.
// Print: ABS/ASA (chamber runs 50-65 C, PLA/PETG will creep), 5 walls, 40% infill. No supports needed.
//
// !! Z CLEARANCE: the spool hangs ~(gap + spool_d + 2*clear) below the rail. The gantry/toolhead sweeps the
//    whole chamber footprint as Z rises, so a tall print will hit the spool. Lower position_max for
//    [stepper_z] in printer.cfg to what is left (measure at your printer), or mount it in a top hat.

part = "assembly";

/* ---- spool (standard 1 kg) ---- */
spool_d   = 200;     // outer diameter (most 1 kg spools 195-205)
spool_w   = 70;      // width across the flanges (some brands 65-75)
hub_d     = 52;      // smallest hub hole you use (52-55 typical; cardboard 1 kg ~ 52-57)

/* ---- clearances ---- */
clear     = 5;       // spool rim to rail face / rail bottom
side_gap  = 5;       // total sideways play of the spool between the arms

/* ---- rail ---- */
ext = 20;
m5_clear = 5.5; m5_head_d = 10; under_head = 5;   // 5 mm of plastic under the head -> M5x10 + T-nut
key_w = 5.8; key_h = 1.5;                          // slot keys stop the arm twisting on the rail

/* ---- arm ---- */
t      = 12;         // arm thickness (X)
plate  = 8;          // L clamp plate thickness
strut  = 22;         // strut width
boss_r = 17;         // hook boss radius

/* ---- axle ---- */
axle_d   = hub_d - 6;       // 46 for a 52 hub: loose so cardboard / warped hubs still roll
axle_id  = axle_d - 14;     // hollow
pin_d    = 16;              // end pins that drop into the hook slots
slot_w   = pin_d + 0.8;
slot_ang = 25;              // slot opens up and tilted this far toward the chamber

/* ---- derived ---- */
inner     = spool_w + side_gap;                 // gap between the arms' inner faces
axle_len  = inner - 1;                          // shoulders locate the axle between the arms
axle_y    = clear + spool_d/2;                  // axle centre in front of the rail face
axle_z    = -(plate + clear + spool_d/2);       // axle centre below the rail bottom
drop      = -axle_z + spool_d/2;                // lowest point of the spool below the rail bottom

echo(str("Arm inner faces ", inner, " mm apart (outer ", inner + 2*t, "). Axle centre ", axle_y,
         " mm in front of rail, ", -axle_z, " mm below it. Spool bottom ", drop, " mm below rail bottom."));

$fn = 64;

// One arm, modelled in YZ (2D) and extruded along X by t.
module arm_2d() {
  difference() {
    union() {
      // L clamp: vertical plate on the inner face, ledge under the rail
      translate([0, 0]) square([plate, ext]);
      translate([-ext + 1, -plate]) square([ext - 1 + plate, plate]);
      // main strut from the clamp corner to the hook boss
      hull() { translate([0, -plate]) square([plate, plate]); translate([axle_y, axle_z]) circle(r = strut/2); }
      // upper strut from the top of the plate (takes the bolt-tension side) to the boss
      hull() { translate([0, ext - 8]) square([plate, 8]); translate([axle_y, axle_z]) circle(r = strut/2); }
      // web between the two struts near the clamp
      hull() { translate([0, -plate]) square([plate, ext + plate]); translate([28, -28]) circle(r = 4); }
      translate([axle_y, axle_z]) circle(r = boss_r);
    }
    // hook slot: round seat + straight entry opening up/forward
    translate([axle_y, axle_z]) {
      circle(d = slot_w);
      rotate(-slot_ang) translate([-slot_w/2, 0]) square([slot_w, boss_r + 5]);
    }
  }
}

module arm() {
  difference() {
    union() {
      rotate([90, 0, 90]) linear_extrude(t) arm_2d();
      // slot keys into the rail's inner-face slot and bottom slot
      translate([0, -key_h, ext/2 - key_w/2]) cube([t, key_h + 0.01, key_w]);
      translate([0, -ext/2 - key_w/2, -0.01]) cube([t, key_w, key_h]);
    }
    // M5 into the inner-face slot (horizontal, along Y)
    translate([t/2, 0, ext/2]) rotate([-90, 0, 0]) {
      translate([0, 0, -5]) cylinder(d = m5_clear, h = plate + 10);
      translate([0, 0, under_head]) cylinder(d = m5_head_d, h = 60);
    }
    // M5 into the bottom slot (vertical)
    translate([t/2, -ext/2, 0]) rotate([180, 0, 0]) {
      translate([0, 0, -5]) cylinder(d = m5_clear, h = plate + 10);
      translate([0, 0, under_head]) cylinder(d = m5_head_d, h = 60);
    }
  }
}

module axle() {   // standing up, Z = axle length direction
  difference() {
    union() {
      cylinder(d = axle_d, h = axle_len);
      translate([0, 0, -t - 2]) cylinder(d = pin_d, h = axle_len + 2*t + 4);
      // small chamfer cones so the spool slides on easily
    }
    translate([0, 0, 3]) cylinder(d = axle_id, h = axle_len - 6);
    // chamfer the shoulder edges
    for (z = [0, axle_len]) translate([0, 0, z])
      rotate_extrude() translate([axle_d/2, 0]) rotate(45) square(2.2, center = true);
  }
}

module rail_mock(len = 200) {
  color("dimgray") difference() {
    translate([-len/2, -ext, 0]) cube([len, ext, ext]);
    for (a = [[0, -ext/2, ext - 3], [0, -3, ext/2], [0, -ext/2, 3], [0, -ext + 3, ext/2]])
      translate([-len/2 - 1, a[1] - 3, a[2] - 3]) cube([len + 2, 6, 6]);
  }
}

module spool_mock() {
  color("orange", 0.8) rotate([0, 90, 0]) difference() {
    union() {
      translate([0, 0, -spool_w/2]) cylinder(d = spool_d, h = 3);
      translate([0, 0, spool_w/2 - 3]) cylinder(d = spool_d, h = 3);
      translate([0, 0, -spool_w/2]) cylinder(d = spool_d - 40, h = spool_w);
    }
    translate([0, 0, -spool_w]) cylinder(d = hub_d, h = 2*spool_w);
  }
}

module assembly() {
  rail_mock(260);
  color("steelblue") {
    translate([inner/2, 0, 0]) arm();
    translate([-inner/2, 0, 0]) mirror([1, 0, 0]) arm();
  }
  color("lightsteelblue") translate([-axle_len/2, axle_y, axle_z]) rotate([0, 90, 0]) axle();
  translate([0, axle_y, axle_z]) spool_mock();
}

if (part == "arm") rotate([0, -90, 0]) arm();          // lie flat on the big face
else if (part == "axle") translate([0, 0, t + 2]) axle();
else assembly();
