// HMTECH / HAMTYSAN 10.1" HDMI touchscreen (1024x600, model HM10.1-RP) - FLUSH DIRECT-BOLT version.
// The bezel has two ears that bolt straight to the FRONT face of a horizontal 2020 rail (door top rail), no hinge, no arm.
// The screen hangs in the opening just under the rail, as far back as the glass behind it allows.
// A slim open channel for the HDMI / USB plugs is part of the bezel (replaces the separate port guard box).
// Parts: "bezel" (new), "retainer" (identical to hmtech10_retainer.stl from hmtech10_case.scad), "assembly"
// For a 256 mm bed (Bambu X1C): "bezel_split" (248 wide, no channel) + "plug_cover" (the channel as a clip-on piece that
// slides onto two dovetails from the back and is locked by the retainer); preview with "assembly_split".
// Corner mount: "bezel_corner" (X1C size, uses "plug_cover" + "retainer"). Top edge flush with the door top, a header strip
// bolts to the front of the door's top rail, the case can slide all the way into the corner; preview with "assembly_corner".
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

/* ---- Direct mount ---- */
m5 = 5.4;
rail_z   = 17;       // bezel front face -> front face of the rail. Smaller = more flush.
glass_inset = 7;     // how far the door glass sits behind the rail's front face (ASSUMED - measure it)
rear_max = 13;       // tallest thing behind the panel (driver board + connectors), conservative
                     // rule: lip_t + panel_t + rear_max <= rail_z + glass_inset - 1   (23 <= 23 with the defaults)
ear_w   = 20;        // width of each bolt ear
ear_gap = 1.5;       // case top edge sits this far below the rail's bottom edge
ear_x   = [50, 198.2];   // ear centres along the top edge (any spacing works with T-nuts)
ear_flange = 5;      // plastic under the M5 head (M5x10 + T-nut)

/* ---- Plug channel on the port side (rear view: right; from the front: left) ---- */
wing_len   = 42;     // past the case edge: covers a straight HDMI plug body. ~22 is enough with right-angle adapters
wing_h     = 23;     // wall height from the front face (plugs reach ~22.5)
wing_wall  = 2.5;  wing_floor = 2.5;
tie_y = [32, 46.5];  // zip tie loops on the channel floor (PANEL y): under the micro-USB and under the HDMI plug

/* ---- Corner version ---- */
corner_z  = 24;      // bezel front face -> rail front faces. 24 so the driver board and plugs clear the rails when the
                     // case sits over the hinge-side upright (they reach 23 behind the front face)
corner_hd = 16;      // header strip above the case: covers the top rail, M5 holes on the rail's slot line (10 below the top)
corner_bolt_x = [40, 208.2];   // M5 positions along the header (T-nuts slide, any spacing works)

/* ---- Split version: dovetails that hold the clip-on plug cover ---- */
dv_y = [10, 81];     // dovetail centres along the right wall (case coords), both under the retainer
dv_d = 3.4; dv_root = 6; dv_tip = 10;   // dovetail depth into the wall, width at the face, width at the tip
dv_clr = 0.2;        // slot clearance per side

$fn = 48;
ow = glass_w + 2*clr + 2*wall;
oh = glass_h + 2*clr + 2*wall;
depth = lip_t + panel_t;
p0 = wall + clr;     // panel origin in case coords
echo(clearance_to_glass = rail_z + glass_inset - (depth + rear_max));

module rrect(w, h, t, r) { linear_extrude(t) offset(r) offset(-r) square([w, h]); }

sp_in = wall/2 + 0.4;   // screw centre from the outer edge
screw_pts = concat(
  [ for (x=[0.04, 0.35, 0.65, 0.96]) [ow*x, oh-sp_in] ],                 // top
  [ for (x=[ow*0.04, 55, 98, p0+160.5, ow*0.96]) [x, sp_in] ],           // bottom (between the flex reliefs)
  [ [sp_in, oh*0.62] ],                                                   // left (above the Pi notch)
  [ [ow-sp_in, p0+port_y1+19], [ow-sp_in, oh*0.80] ] );                   // right (above the port opening)

module screw_holes(t) for (p = screw_pts) translate([p[0], p[1], -1]) {
  cylinder(d=m3_clear, h=t+2);
  translate([0,0,t-1.6+1]) cylinder(d=6, h=2);   // counterbore for the head
}

// One bolt ear, local origin = centre of its foot on the top edge. Solid from the front face back to the rail face,
// so the bezel still prints front-face down with no support. The M5 head sits in a pocket reached from the front.
module ear_solid() {
  eh = ear_gap + 19;                       // reaches 1 mm short of the rail's top edge
  translate([-ear_w/2, -0.01, 0]) cube([ear_w, 2, depth]);
  translate([0, 0.4, 0]) linear_extrude(rail_z) hull() {    // 0.4 back from the edge so the retainer drops in
    translate([-ear_w/2, 0]) square([ear_w, 1]);
    for (s=[-1,1]) translate([s*(ear_w/2-4), eh-0.4-4]) circle(r=4);
  }
}
module ear_cut() translate([0, ear_gap+10, 0]) {            // rail slot centre line
  translate([0,0,-1]) cylinder(d=m5, h=rail_z+2);
  translate([0,0,-1]) cylinder(d=10, h=rail_z-ear_flange+1);
}

// Dovetail, local frame: origin on the right wall face, +x = INTO the wall, z up from the front face.
// The last 1 mm flares out at 45 deg so the cover cannot slide forward; the retainer stops it sliding back.
module dove2d(c) offset(delta=c) polygon([[-0.01,-dv_root/2],[dv_d,-dv_tip/2],[dv_d,dv_tip/2],[-0.01,dv_root/2]]);
module dove(c=0, h=depth) {
  linear_extrude(h-1) dove2d(c);
  translate([0,0,h-1.001]) hull() {
    linear_extrude(0.01) dove2d(c);
    translate([0,0,1]) linear_extrude(0.01) intersection() { offset(delta=1) dove2d(c); translate([-0.01,-50]) square([50,100]); }
  }
}
module dove_at(i) translate([ow, dv_y[i], 0]) mirror([1,0,0]) children();

// Clip-on plug cover for the split version: the same channel, plus two arms along the case edge that carry the dovetails.
module plug_cover() {
  wy0 = p0+plug_y0-wing_wall; wy1 = p0+plug_y1+wing_wall;
  intersection() { wing(); translate([ow, -1, -1]) cube([wing_len+10, oh, wing_h+2]); }   // butts against the case edge
  for (i=[0,1]) dove_at(i) dove(0, depth-0.1);
  translate([ow, dv_y[0]-7, 0]) cube([5, wy0+0.01-(dv_y[0]-7), depth-0.1]);
  translate([ow, wy1-0.01, 0]) cube([5, dv_y[1]+7-wy1+0.01, depth-0.1]);
}

// Open channel for the plugs: floor flush with the front face, a wall above and below, open at the back and at the end.
module wing() {
  wy0 = p0+plug_y0-wing_wall; wy1 = p0+plug_y1+wing_wall;
  difference() {
    translate([ow-0.01, wy0, 0]) linear_extrude(wing_h) hull() {
      square([1, wy1-wy0]);
      for (y=[4, wy1-wy0-4]) translate([wing_len-4, y]) circle(r=4);
    }
    translate([ow-0.02, wy0+wing_wall, wing_floor]) cube([wing_len+1, wy1-wy0-2*wing_wall, wing_h]);
  }
  // zip tie loops: the tie goes under the bar and round the plug / cable
  for (y = tie_y) translate([ow+wing_len-11, p0+y-1.5, wing_floor-0.01]) {
    for (x=[0, 7]) translate([x,0,0]) cube([2, 3, 2.2]);
    translate([0,0,2.2-0.01]) cube([9, 3, 1.8]);
  }
}

module bezel(split=false, corner=false) {
  difference() {
    union() {
      rrect(ow, oh + (corner ? corner_hd : 0), depth, r_out);
      if (!corner) for (x = ear_x) translate([x, oh, 0]) ear_solid();
      if (corner) translate([0, oh+0.4, 0]) rrect(ow, corner_hd-0.4, corner_z, r_out);   // header, solid back to the rail
      if (!split) wing();
    }
    if (corner) for (x = corner_bolt_x) translate([x, oh+corner_hd-10, -1]) {
      cylinder(d=m5, h=corner_z+2);
      cylinder(d=10, h=corner_z-ear_flange+1);      // pocket for the M5 head, reached from the front
    }
    if (split) for (i=[0,1]) dove_at(i) translate([0,0,-1]) dove(dv_clr, depth+1.02);
    if (!corner) for (x = ear_x) translate([x, oh, 0]) ear_cut();
    // panel pocket
    translate([wall, wall, lip_t]) cube([glass_w+2*clr, glass_h+2*clr, depth]);
    // flex reliefs in the bottom wall
    translate([p0+tflex_x0, wall-tflex_relief, lip_t]) cube([tflex_x1-tflex_x0, tflex_relief+1, depth]);
    translate([p0+lflex_x0, wall-lflex_relief, lip_t]) cube([lflex_x1-lflex_x0, lflex_relief+1, depth]);
    // lower the right wall under the HDMI / USB plugs
    translate([ow-wall-1, p0+plug_y0, depth-plug_relief]) cube([wall+1.01, plug_y1-plug_y0, plug_relief+1]);
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

if (part == "bezel") bezel();
else if (part == "bezel_split") bezel(true);
else if (part == "bezel_corner") bezel(true, true);
else if (part == "assembly_corner") {
  color("dimgray") bezel(true, true);
  color("steelblue") plug_cover();
  color("black", 0.8) translate([p0, p0, lip_t]) cube([glass_w, glass_h, panel_t]);
  color("silver") translate([0,0,depth]) retainer();
  // door corner, rear view: top rail level with the header top, hinge-side upright under the case's port end
  dt = oh + corner_hd;
  color("lightsteelblue", 0.6) translate([-150, dt-20, corner_z]) cube([ow+150, 20, 20]);
  color("lightsteelblue", 0.6) translate([ow-20, -150, corner_z]) cube([20, dt-20+150, 20]);
}
else if (part == "plug_cover") translate([-ow, 0, 0]) plug_cover();
else if (part == "retainer") retainer();
else {
  split = (part == "assembly_split");
  color("dimgray") bezel(split);
  if (split) color("steelblue") plug_cover();
  color("black", 0.8) translate([p0, p0, lip_t]) cube([glass_w, glass_h, panel_t]);
  color("silver") translate([0,0,depth]) retainer();
  // door frame, rear view: top rail above the case, glass behind it
  ry = oh + ear_gap;
  color("lightsteelblue", 0.6) translate([-120, ry, rail_z]) cube([ow+wing_len+70+120, 20, 20]);
  color("lightsteelblue", 0.6) translate([ow+wing_len+50, -120, rail_z]) cube([20, ry+120, 20]);
  color("lightcyan", 0.25) translate([-120, -120, rail_z+glass_inset]) cube([ow+wing_len+50+120, ry+120, 3]);
}
