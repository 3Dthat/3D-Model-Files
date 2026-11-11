// Hosyond 7" DSI touchscreen (800x480, ASIN B0D3QB7X4Z) case + 2020 extrusion tilt mount
// Parts: "bezel", "retainer", "arm" (side face), "arm_bottom" (under extrusion, reaches forward), "arm_top" (top face), "arm_end" (extrusion end), "assembly"
part = "assembly";
mount = "side";      // assembly preview: "side", "top", "end"
fork_mount = "bezel_top"; // "bezel_top" = forks stick UP out of the bezel top edge (screen hangs flat); "retainer" = forks on the back frame
fork_h = 11;         // bezel_top: top edge -> hinge axis
hinge_edge = "top";  // "top"/"bottom" = tilts up/down, "side" = hinge on a short edge, swivels left/right

/* ---- Screen (MEASURE panel_t on yours!) ---- */
// From manufacturer drawing (7inch DSI Display User Manual V1.1). Model coords = REAR view.
glass_w  = 164.9;    // PCB/backlight outline (lens is 164.28, flush on front-left)
glass_h  = 102.0;    // PCB/backlight outline (lens is 99.17, flush on top)
panel_t  = 9.0;      // glass + metal frame + blue PCB at the edge (measured 9.0 mm)
active_w = 154.68; active_h = 87.02;   // viewing area
win_margin = 0.5;    // extra window beyond viewing area each side
chamfer = 0.8;       // front edge chamfer on the window
win_dx = 1.75; win_dy = 3.45;  // VA is off-center: 3.3 mm from front-left, 4.0 mm from top
clr = 0.5;           // pocket clearance per side

/* ---- Case ---- */
wall   = 6;          // side wall (M3 pilot holes go into its top)
lip_t  = 2;          // front bezel thickness
r_out  = 4;          // outer corner radius
border = 4;          // how far the back retainer overlaps the panel edge (keep clear of rear standoffs)
ret_t  = 5;          // retainer plate thickness (was 3, too fragile)
m3_pilot = 2.6;      // for M3 self-tapping into bezel walls
m3_clear = 3.4;

/* ---- Mount ---- */
m5 = 5.4;
ear_t = 5;  knuckle_w = 10.4;  ear_h = 20;  ear_d = 14;   // hinge ears on retainer
arm_len = 35;        // hinge axis -> extrusion face
extrusion_vertical = false;  // true = 2020 runs vertically, false = horizontally
tnut_spacing = 20;
top_drop = 12;       // arm_top: hinge axis -> top of plate (screen clearance)
end_len  = 50;       // arm_end: hinge axis -> extrusion end face
fwd_offset = 46;     // arm_bottom: hinge in front of the extrusion face (46 keeps the screen back ~38 mm in front of the 2020 with bezel_top forks)
bot_drop   = 16;     // arm_bottom: extrusion bottom face -> hinge axis

$fn = 48;
ow = glass_w + 2*clr + 2*wall;
oh = glass_h + 2*clr + 2*wall;
depth = lip_t + panel_t;

// rear-view features (case coords)
btn_x0 = wall+clr+13;  btn_x1 = wall+clr+29;     // backlight button on top edge (16.6-25.2 mm from rear-left)
ffc_y0 = wall+clr+28;  ffc_y1 = wall+clr+56;     // DSI ribbon exits toward the rear-right edge

module rrect(w, h, t, r) {
  linear_extrude(t) offset(r) offset(-r) square([w, h]);
}

sp_in = wall/2 + 0.4;   // screw centre from outer edge (keeps the 6 mm counterbore off the edge)
screw_pts = concat([ for (x=[0.06, 0.5, 0.94]) for (y=[0,1]) [ow*x, y==0 ? sp_in : oh-sp_in] ],
                   [ [sp_in, oh/2], [ow-sp_in, oh/2] ]);

module bezel_forks() {
  for (s=[-1,1]) translate([ow/2 + s*(knuckle_w/2 + ear_t/2) - ear_t/2, oh-0.5, 0])
    difference() {
      hull() {
        cube([ear_t, 0.6, depth]);
        translate([0, fork_h+0.5, depth/2]) rotate([0,90,0]) cylinder(d=depth, h=ear_t);
      }
      translate([-1, fork_h+0.5, depth/2]) rotate([0,90,0]) cylinder(d=m5, h=ear_t+2);
      if (s==1) translate([ear_t-2.5, fork_h+0.5, depth/2]) rotate([0,90,0]) cylinder(d=9.4, h=3, $fn=6);
    }
}

module bezel() {
  if (fork_mount == "bezel_top") bezel_forks();
  difference() {
    rrect(ow, oh, depth, r_out);
    // panel pocket
    translate([wall, wall, lip_t]) cube([glass_w+2*clr, glass_h+2*clr, depth]);
    // viewing window with 45deg chamfer toward the front
    ww = active_w + 2*win_margin; wh = active_h + 2*win_margin;
    translate([ow/2+win_dx, oh/2+win_dy, -0.01])
      union() {
        linear_extrude(lip_t+0.1) square([ww, wh], center=true);
        hull() {
          translate([0,0,chamfer]) linear_extrude(0.02) square([ww, wh], center=true);
          linear_extrude(0.02) square([ww+2*chamfer, wh+2*chamfer], center=true);
        }
      }
    // backlight button access slot in the top wall
    translate([btn_x0, oh-wall-1, lip_t+5.15]) cube([btn_x1-btn_x0, wall+2, depth]);
    // screw pilots in wall tops
    for (p = screw_pts) translate([p[0], p[1], lip_t+0.5]) cylinder(d=m3_pilot, h=depth);
  }
}

// places children in hinge frame: origin at screen-edge midpoint, local y = inward
module hinge_frame() {
  if (hinge_edge == "side") translate([0, oh/2, 0]) rotate([0,0,-90]) children();
  else if (hinge_edge == "top") translate([ow/2, oh, 0]) rotate([0,0,180]) children();
  else translate([ow/2, 0, 0]) children();
}

module ears() {
  hinge_frame() for (s=[-1,1]) translate([s*(knuckle_w/2 + ear_t/2) - ear_t/2, 0.5, ret_t-0.01])
    difference() {
      hull() {
        cube([ear_t, ear_d, 0.1]);
        translate([0, ear_d/2, ear_h-ear_d/2]) rotate([0,90,0]) cylinder(d=ear_d, h=ear_t);
      }
      translate([-1, ear_d/2, ear_h-ear_d/2]) rotate([0,90,0]) cylinder(d=m5, h=ear_t+2);
      // nut trap on one side
      if (s==1) translate([ear_t-2.5, ear_d/2, ear_h-ear_d/2]) rotate([0,90,0]) cylinder(d=9.4, h=3, $fn=6);
    }
}

module retainer() {
  difference() {
    rrect(ow, oh, ret_t, r_out);
    translate([wall+clr+border, wall+clr+border, -1])
      rrect(glass_w-2*border, glass_h-2*border, ret_t+2, 3);
    for (p = screw_pts) translate([p[0], p[1], -1]) {
      cylinder(d=m3_clear, h=ret_t+2);
      translate([0,0,ret_t-1.6]) cylinder(d=6, h=2);   // counterbore for head
    }
    // backlight button window (stops at the PCB edge so the outer rim stays unbroken)
    translate([btn_x0, oh-wall-clr-border-1, -1]) cube([btn_x1-btn_x0, border+2*clr+1, ret_t+2]);
    // clearance for anything fitted in the 4 corner mounting holes (5 mm in from the PCB edges)
    for (h=[[5,5.04],[159.89,5.04],[5,96.96],[159.89,96.96]])
      translate([wall+clr+h[0], wall+clr+h[1], -1]) cylinder(d=7.5, h=ret_t+2);
    // DSI ribbon notch in the right border
    translate([ow-wall-clr-border-1, ffc_y0, -1]) cube([border+clr+1.01, ffc_y1-ffc_y0, ret_t+2]);
  }
  if (fork_mount == "retainer") {
    // solid pad under the hinge ears (fills the opening locally)
    difference() {
      hinge_frame() translate([-(knuckle_w/2+ear_t), 0.5, 0]) cube([knuckle_w+2*ear_t, ear_d, ret_t]);
      for (p = screw_pts) translate([p[0], p[1], -1]) {
        cylinder(d=m3_clear, h=ret_t+2);
        translate([0,0,ret_t-1.6]) cylinder(d=6, h=2);
      }
    }
    ears();
  }
}

module arm() {
  kd = ear_d;                 // knuckle diameter
  pw = extrusion_vertical ? 20 : 40;  // plate along x
  ph = extrusion_vertical ? 40 : 20;  // plate along y
  difference() {
    union() {
      // knuckle (axis along x)
      rotate([0,90,0]) cylinder(d=kd, h=knuckle_w-0.4, center=true);
      // arm bar
      translate([-(knuckle_w-0.4)/2, -kd/2, 0]) cube([knuckle_w-0.4, kd, arm_len-6]);
      // gussets
      hull() {
        translate([-(knuckle_w-0.4)/2, -kd/2, arm_len-20]) cube([knuckle_w-0.4, kd, 1]);
        translate([-pw/2, -ph/2, arm_len-6]) cube([pw, ph, 0.1]);
      }
      // extrusion plate
      translate([-pw/2, -ph/2, arm_len-6]) cube([pw, ph, 6]);
      // slot key (6mm 2020 slot)
      kl = extrusion_vertical ? [5.8, ph, 1.8] : [pw, 5.8, 1.8];
      translate([-kl[0]/2, -kl[1]/2, arm_len]) cube(kl);
    }
    rotate([0,90,0]) cylinder(d=m5, h=knuckle_w+2, center=true);
    // T-nut bolts with counterbores from the arm side
    for (s=[-1,1]) {
      p = extrusion_vertical ? [0, s*tnut_spacing/2] : [s*tnut_spacing/2, 0];
      translate([p[0], p[1], arm_len-30]) cylinder(d=m5, h=40);
      translate([p[0], p[1], arm_len-30]) cylinder(d=9.5, h=30-3.5);
    }
  }
}


module knuckle() {
  difference() {
    rotate([0,90,0]) cylinder(d=ear_d, h=knuckle_w-0.4, center=true);
    rotate([0,90,0]) cylinder(d=m5, h=knuckle_w+2, center=true);
  }
}

// Bolts onto the TOP (or bottom) face of a horizontal 2020; screen stands above it.
module arm_top() {
  kw = knuckle_w-0.4; pt = 6;
  difference() {
    union() {
      rotate([0,90,0]) cylinder(d=ear_d, h=kw, center=true);
      translate([-kw/2, -top_drop, -ear_d/2]) cube([kw, top_drop, ear_d]);
      // gusset
      hull() {
        translate([-kw/2, -top_drop+0.01, -ear_d/2]) cube([kw, 0.1, ear_d]);
        translate([-20, -top_drop, -8]) cube([40, 0.1, 20]);
        translate([-kw/2, -ear_d/2, -ear_d/2]) cube([kw, 0.1, ear_d]);
      }
      translate([-20, -top_drop-pt, -8]) cube([40, pt, 20]);           // plate
      translate([-20, -top_drop-pt-1.8, 2-2.9]) cube([40, 1.8, 5.8]);  // slot key
    }
    rotate([0,90,0]) cylinder(d=m5, h=knuckle_w+2, center=true);
    for (s=[-1,1]) translate([s*tnut_spacing/2, -top_drop-pt-3, 2]) rotate([-90,0,0]) {
      cylinder(d=m5, h=20);
      translate([0,0,pt+3-3.5+3.5]) cylinder(d=9.5, h=20);
    }
  }
}

// Socket that caps the END of a 2020, fixed with one M5 into the tapped center hole.
module arm_end() {
  kw = knuckle_w-0.4; L = end_len; cup = 28;
  difference() {
    union() {
      rotate([0,90,0]) cylinder(d=ear_d, h=kw, center=true);
      translate([-kw/2, -ear_d/2, 0]) cube([kw, ear_d, 14]);
      for (s=[-1,1]) translate([s*7.5-2.5, -ear_d/2, 10]) cube([5, ear_d, L-10]);  // yoke walls
      hull() {
        translate([-10, -ear_d/2, L-14]) cube([20, ear_d, 0.1]);
        translate([-cup/2, -cup/2, L-6]) cube([cup, cup, 0.1]);
      }
      translate([-cup/2, -cup/2, L-6]) cube([cup, cup, 11]);           // cup
    }
    rotate([0,90,0]) cylinder(d=m5, h=knuckle_w+2, center=true);
    translate([-5, -ear_d, 14]) cube([10, 2*ear_d, L-14-6]);           // tool window
    translate([-10.25, -10.25, L]) cube([20.5, 20.5, 6]);              // extrusion pocket
    translate([0,0,L-10]) cylinder(d=m5, h=12);                        // M5 bolt
  }
}

// Bolts to the BOTTOM face of a horizontal 2020 and reaches forward, so the screen
// hangs in front of whatever is below the extrusion (e.g. Voron front skirts).
// Local frame: +z = toward the extrusion (rear), -y = up.
module arm_bottom() {
  kw = knuckle_w-0.4; pt = 6; F = fwd_offset; D = bot_drop;
  zc = F + 10;                       // extrusion center (rear of hinge)
  difference() {
    union() {
      rotate([0,90,0]) cylinder(d=ear_d, h=kw, center=true);
      // diagonal web from knuckle to plate
      hull() {
        translate([-kw/2, -ear_d/2, -ear_d/2]) cube([kw, ear_d, ear_d]);
        translate([-kw/2, -D+pt-0.1, F]) cube([kw, 0.1, 20]);
      }
      // gusset under plate
      hull() {
        translate([-kw/2, -D+pt, F]) cube([kw, 6, 20]);
        translate([-20, -D+pt-0.1, F]) cube([40, 0.1, 20]);
      }
      translate([-20, -D, F]) cube([40, pt, 20]);                    // plate
      translate([-20, -D-1.8, zc-2.9]) cube([40, 1.8, 5.8]);         // slot key
    }
    rotate([0,90,0]) cylinder(d=m5, h=knuckle_w+2, center=true);
    for (s=[-1,1]) translate([s*tnut_spacing/2, -D-3, zc]) rotate([-90,0,0]) {
      cylinder(d=m5, h=30);
      translate([0,0,3+pt-0.01]) cylinder(d=9.5, h=30);              // counterbore from below
    }
  }
}

if (part == "bezel") bezel();
else if (part == "retainer") retainer();
else if (part == "arm") rotate([0,-90,0]) arm();   // print on its side
else if (part == "arm_top") rotate([0,-90,0]) arm_top();
else if (part == "arm_end") rotate([0,-90,0]) arm_end();
else if (part == "arm_bottom") rotate([0,-90,0]) arm_bottom();
else {
  color("dimgray") bezel();
  color("black", 0.8) translate([wall+clr, wall+clr, lip_t]) cube([glass_w, glass_h, panel_t]);
  color("silver") translate([0,0,depth]) retainer();
  if (fork_mount == "bezel_top") {
    // screen hangs from forks on the bezel top edge; arm_bottom under the 2020
    translate([ow/2, oh+fork_h, depth/2]) rotate([0,0,180]) {
      color("orange") arm_bottom();
      color("lightsteelblue", 0.6) translate([-150, -bot_drop-20, fwd_offset]) cube([300, 20, 20]);
    }
  } else
  hinge_frame() translate([0, 0.5+ear_d/2, depth+ret_t+ear_h-ear_d/2]) {
    if (mount == "bottom") {
      color("orange") arm_bottom();
      color("lightsteelblue", 0.6) translate([-150, -bot_drop-20, fwd_offset]) cube([300, 20, 20]);
    } else if (mount == "top") {
      color("orange") arm_top();
      color("lightsteelblue", 0.6) translate([-150, -top_drop-6-20, -8]) cube([300, 20, 20]);
    } else if (mount == "end") {
      color("orange") arm_end();
      color("lightsteelblue", 0.6) translate([-10, -10, end_len]) cube([20, 20, 200]);
    } else {
      color("orange") arm();
      color("lightsteelblue", 0.6)
        if (extrusion_vertical) translate([-10,-150,arm_len]) cube([20,300,20]);
        else translate([-150,-10,arm_len]) cube([300,20,20]);
    }
  }
}
