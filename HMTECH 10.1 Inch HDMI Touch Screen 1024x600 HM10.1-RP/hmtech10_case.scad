// HMTECH / HAMTYSAN 10.1" HDMI touchscreen (1024x600, model HM10.1-RP, panel HCIK101V-CC)
// Landscape case that hangs from the SAME arm_bottom bracket as the 7" case.
// Parts: "bezel", "retainer", "guard" (box over the HDMI/USB plugs), "arm_bottom", "assembly"
// Door mount (screen flat on a 2020-framed door, top-left corner): "arm_door" + "guard_door" replace arm_bottom + guard;
// preview it with part = "assembly_door". Bezel and retainer are the same parts.
part = "assembly";

/* ---- Screen. Model coords = REAR view: driver board along the BOTTOM edge, HDMI/USB ports on the RIGHT edge.
        Seen from the front the cables leave on the LEFT. ---- */
glass_w  = 235.0;    // glass / metal tray outline (listing 9.25 in; tape photo ~234.5)
glass_h  = 143.0;    // (listing 5.62 in; tape photo ~142.5)
panel_t  = 8.0;      // glass + metal tray at the edge, measured by Jason with calipers (listing said 0.27 in)
active_w = 222.72; active_h = 125.28;   // viewing area of the 10.1" 1024x600 panel
win_margin = 1.0;    // extra window beyond the viewing area each side
chamfer = 0.8;
win_dx = 0.75; win_dy = 0;  // black border: ~5.4 mm at the port end, ~6.9 mm at the far end, ~8.9 top and bottom
clr = 0.6;           // pocket clearance per side

/* ---- Rear features, in PANEL coords (rear view, origin = bottom-left corner of the panel) ---- */
board_x0 = 103; board_y0 = 10; board_y1 = 62;   // driver board: reaches the right edge, raised on standoffs
port_y0 = 9;  port_y1 = 68;      // retainer is left open here for the board end and the HDMI / micro-USB plugs
plug_y0 = 22; plug_y1 = 62;      // bezel wall is lowered here under the cable plugs
plug_relief = 2;
tflex_x0 = 174; tflex_x1 = 213;  // black touch flex wraps round the bottom edge (sticks out ~1.5 mm)
lflex_x0 = 101; lflex_x1 = 147;  // orange LCD flex at the bottom edge
tflex_relief = 2.5; lflex_relief = 1.0;   // extra pocket depth into the bottom wall
pi_holes = [[23.5,11.7],[81.5,11.7],[23.5,60.7],[81.5,60.7]];  // Raspberry Pi pattern 58 x 49 on the tray
pi_notch = true;                 // open the left border so a Pi on those holes (USB end overhanging) clears it
pi_y0 = 4; pi_y1 = 68;

/* ---- Case ---- */
wall   = 6;
lip_t  = 2;
r_out  = 4;
border = 5;          // how far the retainer overlaps the back of the panel
ret_t  = 5;
m3_pilot = 2.6;
m3_clear = 3.4;

/* ---- Mount (same hinge as the 7" case: 10.4 gap, M5, axis 11 mm above the top edge) ---- */
m5 = 5.4;
ear_t = 6;  knuckle_w = 10.4;  ear_d = 14;
fork_h = 11;         // top edge -> hinge axis
fork_d = 13;         // fork eye diameter (thicker than the bezel, sticks out the back)
fork_flare = 6;      // extra foot width on the outside of each fork
tnut_spacing = 20;
fwd_offset = 46;     // arm_bottom: hinge in front of the extrusion face
bot_drop   = 16;     // arm_bottom: extrusion bottom face -> hinge axis

/* ---- Port guard: a box that slides onto two dovetails in the right wall and is locked by the retainer ---- */
guard_len  = 70;     // inside length past the case edge (70 = straight HDMI plug + room for the cable to turn back)
guard_h    = 28;     // total height from the front face (plugs reach ~23)
guard_wall = 3;  guard_floor = 2.5;
dv_y = [10, 81];     // dovetail centres along the right wall (case coords), both under the retainer
dv_d = 3.4; dv_root = 6; dv_tip = 10;   // dovetail depth into the wall, width at the face, width at the tip
dv_clr = 0.2;        // slot clearance per side
zip_y = [28, 45.5, 63];  // zip tie posts on the inside of the outer end wall (case y), beside the cables not behind them
zip_gap = 2.4;       // slot between post and wall for the tie

/* ---- Door mount: the guard's back rim sits on the front face of the door frame, so that face is guard_h behind the screen front ---- */
door_ear = 16;       // guard_door: lug past the end wall, M5 T-nut into the upright's front slot (hole 8 mm past the wall)
door_notch = 14;     // guard_door: cable exit notch in the top wall, at the outer end
door_plate = [60, 20, 5];   // arm_door: plate on the front face of the door's top rail, 2x M5 T-nuts 40 mm apart
door_pad = 14;       // arm_door: pad below the plate that rests on the back plate

$fn = 48;
ow = glass_w + 2*clr + 2*wall;
oh = glass_h + 2*clr + 2*wall;
depth = lip_t + panel_t;
p0 = wall + clr;     // panel origin in case coords
fork_z = fork_d/2;   // hinge axis height above the front face

module rrect(w, h, t, r) { linear_extrude(t) offset(r) offset(-r) square([w, h]); }

sp_in = wall/2 + 0.4;   // screw centre from the outer edge
screw_pts = concat(
  [ for (x=[0.04, 0.35, 0.65, 0.96]) [ow*x, oh-sp_in] ],                 // top
  [ for (x=[ow*0.04, 55, 98, p0+160.5, ow*0.96]) [x, sp_in] ],           // bottom (between the flex reliefs)
  [ [sp_in, oh*0.62] ],                                                   // left (above the Pi notch)
  [ [ow-sp_in, p0+port_y1+19], [ow-sp_in, oh*0.80] ] );                   // right (above the port opening and the guard dovetail)

module screw_holes(t) for (p = screw_pts) translate([p[0], p[1], -1]) {
  cylinder(d=m3_clear, h=t+2);
  translate([0,0,t-1.6+1]) cylinder(d=6, h=2);   // counterbore for the head
}

// Dovetail, local frame: origin on the right wall face, +x = INTO the wall, z up from the front face.
// The last 1 mm flares out at 45 deg so the guard cannot slide forward; the retainer stops it sliding back.
module dove2d(c) offset(delta=c) polygon([[-0.01,-dv_root/2],[dv_d,-dv_tip/2],[dv_d,dv_tip/2],[-0.01,dv_root/2]]);
module dove(c=0, h=depth) {
  linear_extrude(h-1) dove2d(c);
  translate([0,0,h-1.001]) hull() {
    linear_extrude(0.01) dove2d(c);
    translate([0,0,1]) linear_extrude(0.01) intersection() { offset(delta=1) dove2d(c); translate([-0.01,-50]) square([50,100]); }
  }
}
module dove_at(i) translate([ow, dv_y[i], 0]) mirror([1,0,0]) children();

// door = true: for the door mount. Adds a lug that bolts to the door upright and a cable exit notch in the top wall
// (the open back sits against the door, so the cables leave upward instead).
module guard(door=false) {
  gy0 = dv_y[0]-7; gy1 = dv_y[1]+7;         // outer faces of the bottom and top walls
  gl = guard_len + guard_wall;
  difference() {
    guard_body(door);
    if (door) {
      // cable exit
      translate([ow+guard_len-door_notch, gy1-guard_wall-1, guard_h-10]) cube([door_notch, guard_wall+2, 11]);
      // M5 through the lug + pocket for the screw head (leaves a 5 mm flange)
      translate([ow+gl+door_ear/2, (gy0+gy1)/2, -1]) { cylinder(d=m5, h=guard_h+2); cylinder(d=10, h=guard_h-5+1); }
    }
  }
}

module guard_body(door) {
  gy0 = dv_y[0]-7; gy1 = dv_y[1]+7;
  gl = guard_len + guard_wall;
  // lug: 45 deg wedge so it prints without support
  if (door) translate([ow+gl-0.01, (gy0+gy1)/2+10, 0]) rotate([90,0,0]) linear_extrude(20)
    polygon([[0, guard_h-5-door_ear], [door_ear, guard_h-5], [door_ear, guard_h], [0, guard_h]]);
  // dovetails + the blocks that carry them
  for (i=[0,1]) {
    dove_at(i) dove(0, depth-0.1);
    translate([ow, dv_y[i]-7, 0]) cube([5, 14, depth-0.1]);
  }
  translate([ow, gy0, 0]) cube([gl, gy1-gy0, guard_floor]);                       // front floor
  translate([ow, gy0, 0]) cube([gl, guard_wall, guard_h]);                        // bottom wall
  translate([ow, gy1-guard_wall, 0]) cube([gl, guard_wall, guard_h]);             // top wall
  translate([ow+guard_len, gy0, 0]) cube([guard_wall, gy1-gy0, guard_h]);         // outer end wall
  // zip tie posts: a tie goes round the cable and through the slot behind a post
  for (y = zip_y) {
    translate([ow+guard_len-zip_gap-3, y-2, 0]) cube([3, 4, guard_h-2]);
    for (z = [guard_h/2-1, guard_h-4]) translate([ow+guard_len-zip_gap-0.5, y-2, z]) cube([zip_gap+1, 4, 2]);  // rungs to the wall
  }
}

module bezel_forks() {
  for (s=[-1,1]) translate([ow/2 + s*(knuckle_w/2 + ear_t/2) - ear_t/2, oh-0.5, 0])
    difference() {
      hull() {
        translate([s==1 ? 0 : -fork_flare, 0, 0]) cube([ear_t+fork_flare, 0.6, depth]);
        translate([0, fork_h+0.5, fork_z]) rotate([0,90,0]) cylinder(d=fork_d, h=ear_t);
      }
      translate([-1, fork_h+0.5, fork_z]) rotate([0,90,0]) cylinder(d=m5, h=ear_t+2);
      if (s==1) translate([ear_t-3, fork_h+0.5, fork_z]) rotate([0,90,0]) cylinder(d=9.4, h=3.5, $fn=6);  // M5 nut trap
    }
}

module bezel() {
  bezel_forks();
  difference() {
    rrect(ow, oh, depth, r_out);
    // panel pocket
    translate([wall, wall, lip_t]) cube([glass_w+2*clr, glass_h+2*clr, depth]);
    // flex reliefs in the bottom wall
    translate([p0+tflex_x0, wall-tflex_relief, lip_t]) cube([tflex_x1-tflex_x0, tflex_relief+1, depth]);
    translate([p0+lflex_x0, wall-lflex_relief, lip_t]) cube([lflex_x1-lflex_x0, lflex_relief+1, depth]);
    // lower the right wall under the HDMI / USB plugs
    translate([ow-wall-1, p0+plug_y0, depth-plug_relief]) cube([wall+2, plug_y1-plug_y0, plug_relief+1]);
    // viewing window with a chamfer toward the front
    ww = active_w + 2*win_margin; wh = active_h + 2*win_margin;
    translate([ow/2+win_dx, oh/2+win_dy, -0.01])
      union() {
        linear_extrude(lip_t+0.1) square([ww, wh], center=true);
        hull() {
          translate([0,0,chamfer]) linear_extrude(0.02) square([ww, wh], center=true);
          linear_extrude(0.02) square([ww+2*chamfer, wh+2*chamfer], center=true);
        }
      }
    // dovetail slots for the port guard
    for (i=[0,1]) dove_at(i) translate([0,0,-1]) dove(dv_clr, depth+1.02);
    // screw pilots in the wall tops
    for (p = screw_pts) translate([p[0], p[1], lip_t+0.5]) cylinder(d=m3_pilot, h=depth);
  }
}

module retainer() {
  difference() {
    rrect(ow, oh, ret_t, r_out);
    translate([p0+border, p0+border, -1]) rrect(glass_w-2*border, glass_h-2*border, ret_t+2, 3);
    screw_holes(ret_t);
    // open on the right for the driver board end and the cable plugs
    translate([ow-p0-border-1, p0+port_y0, -1]) cube([p0+border+2, port_y1-port_y0, ret_t+2]);
    // flex notches in the bottom border (the outer strip stays whole)
    translate([p0+tflex_x0, wall-1.5, -1]) cube([tflex_x1-tflex_x0, clr+border+1.5+1, ret_t+2]);
    translate([p0+lflex_x0, wall-1.0, -1]) cube([lflex_x1-lflex_x0, clr+border+1.0+1, ret_t+2]);
    // Pi notch in the left border (the outer strip stays whole)
    if (pi_notch) translate([wall, p0+pi_y0, -1]) cube([clr+border+1, pi_y1-pi_y0, ret_t+2]);
  }
}

// Door hanger: plate bolts to the FRONT face of the door's top 2020 rail, knuckle goes between the bezel forks.
// Holds the hinge axis guard_h - fork_z in front of the rail face, level with the rail's slot.
// Local frame: +z = toward the rail (rear), knuckle axis along x at the origin.
module arm_door() {
  kw = knuckle_w-0.4; d = guard_h - fork_z; pl = door_plate;
  difference() {
    union() {
      rotate([0,90,0]) cylinder(d=ear_d, h=kw, center=true);
      translate([-kw/2, -ear_d/2, 0]) cube([kw, ear_d, d-pl[2]+0.01]);                 // neck
      hull() {                                                                          // gusset behind the forks
        translate([-kw/2, -ear_d/2, d-pl[2]-8]) cube([kw, ear_d, 0.1]);
        translate([-14, -ear_d/2, d-pl[2]-0.1]) cube([28, ear_d, 0.1]);
      }
      translate([-pl[0]/2, -pl[1]/2, d-pl[2]]) cube(pl);                              // plate
      // pad that rests on the back plate so the screen cannot twist on the knuckle
      translate([-pl[0]/2, -pl[1]/2-door_pad, depth+ret_t+0.3-fork_z]) cube([pl[0], door_pad+0.01, d-(depth+ret_t+0.3-fork_z)]);
    }
    rotate([0,90,0]) cylinder(d=m5, h=knuckle_w+2, center=true);
    for (s=[-1,1]) translate([s*tnut_spacing, 0, d-pl[2]-1]) cylinder(d=m5, h=pl[2]+2);
  }
}

// Bolts to the BOTTOM face of a horizontal 2020 and reaches forward (identical to the 7" case's arm_bottom).
// Local frame: +z = toward the extrusion (rear), -y = up.
module arm_bottom() {
  kw = knuckle_w-0.4; pt = 6; F = fwd_offset; D = bot_drop;
  zc = F + 10;
  difference() {
    union() {
      rotate([0,90,0]) cylinder(d=ear_d, h=kw, center=true);
      hull() {
        translate([-kw/2, -ear_d/2, -ear_d/2]) cube([kw, ear_d, ear_d]);
        translate([-kw/2, -D+pt-0.1, F]) cube([kw, 0.1, 20]);
      }
      hull() {
        translate([-kw/2, -D+pt, F]) cube([kw, 6, 20]);
        translate([-20, -D+pt-0.1, F]) cube([40, 0.1, 20]);
      }
      translate([-20, -D, F]) cube([40, pt, 20]);
      translate([-20, -D-1.8, zc-2.9]) cube([40, 1.8, 5.8]);
    }
    rotate([0,90,0]) cylinder(d=m5, h=knuckle_w+2, center=true);
    for (s=[-1,1]) translate([s*tnut_spacing/2, -D-3, zc]) rotate([-90,0,0]) {
      cylinder(d=m5, h=30);
      translate([0,0,3+pt-0.01]) cylinder(d=9.5, h=30);
    }
  }
}

if (part == "bezel") bezel();
else if (part == "retainer") retainer();
else if (part == "guard") translate([-ow, 0, 0]) guard();
else if (part == "guard_door") translate([-ow, 0, 0]) guard(true);
else if (part == "arm_door") translate([0, 0, guard_h-fork_z]) rotate([180,0,0]) arm_door();   // prints plate-down
else if (part == "assembly_door") {
  color("dimgray") bezel();
  color("black", 0.8) translate([p0, p0, lip_t]) cube([glass_w, glass_h, panel_t]);
  color("silver") translate([0,0,depth]) retainer();
  color("steelblue") guard(true);
  color("orange") translate([ow/2, oh+fork_h, fork_z]) arm_door();
  // door frame: top rail and the hinge-side upright (rear view: upright on the right)
  color("lightsteelblue", 0.6) translate([-150, oh+fork_h-10, guard_h]) cube([ow+guard_len+guard_wall+door_ear/2+10+150, 20, 20]);
  color("lightsteelblue", 0.6) translate([ow+guard_len+guard_wall+door_ear/2-10, -150, guard_h]) cube([20, oh+fork_h-10+150, 20]);
}
else if (part == "arm_bottom") rotate([0,-90,0]) arm_bottom();
else {
  color("dimgray") bezel();
  color("black", 0.8) translate([p0, p0, lip_t]) cube([glass_w, glass_h, panel_t]);
  color("silver") translate([0,0,depth]) retainer();
  color("steelblue") guard();
  translate([ow/2, oh+fork_h, fork_z]) rotate([0,0,180]) {
    color("orange") arm_bottom();
    color("lightsteelblue", 0.6) translate([-150, -bot_drop-20, fwd_offset]) cube([300, 20, 20]);
  }
}
