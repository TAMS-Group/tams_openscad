/** lwr_flange.scad
 * 
 * Simplified models of the Kuka LWR-4+ tool mounting flange and
 * (cable-passthrough) distance plate.
 *
 * 2023.07.03 - created
 *
 * (c) 2023, fnh, hendrich@informatik.uni-hamburg.de
 */
 
 
eps = 0.1;
$fn = 100;
ee = 30; // "explosion" distance, use 0 for STL export
 
 
translate( [0,0,0] ) lwr_tool_flange(); // link7

color( "gold", 0.5 ) translate( [0,0,1*ee-12] ) lwr_distance_plate();

// "TAMS flange" core adapter for the Kuka LWR4+
translate( [0,0,2*ee-12] ) lwr_tams_flange_adapter();

// "TAMS flange" outer adapter for the Schunk WSG-50 gripper
translate( [0,0,3*ee] ) tams_wsg50_adapter();

// Optional traditional mount plate for the WSG-50 
//translate( [0,0,5*ee] ) lwr_wsg50_mount_plate();

// Simplified CAD model of the WSG-50 housing
translate( [0,0,5.5*ee +6 ] ) wsg_50_gripper();

// Optional mounting plate for our "tactile exploration" setup
// use <../sensors/ati-nano17e.scad>
// translate( [0,0,5*ee] ) lwr_ati_nano_plate();



/** simplified model of the LWR4+ tool flange, ISO 9409-1-50-4-M
 *  d_outer = 75, d_flange = 63, d_screws = 50, d_inner = 31.5,
 *  four screws M6 depth 5 (!), 
 *  one alignment pin d=6.
 *  Note that the robot actually has 7 M6 threads, but only
 *  four are specified/used for ISO 9409-1-50-4-M.
 *  Model is centered in x and y, with tool flange at z=0.
 */
module lwr_tool_flange()
{
  d_flange = 63.0; d_screws = 50.0; d_inner = 31.50;
  h_flange = 45.75; h_top = 6.50; h_inner = 6.20; h_bevel = 1.0;
  d_sphere = 140.0;
  h_cone = 15;
  l_screw_bore = 5.0;

  union() {
    // main robot A6+A7 sphere 
    color( "orange" )
    intersection() {
      translate( [0,0,-d_sphere/2] )
        sphere( d=d_sphere, $fn=100 );
      translate( [0, 0, -d_sphere/2-h_cone] )
        cube( [d_sphere, d_sphere, d_sphere], center=true );
    }

    color( "black" )
    translate( [0,0,-h_top-h_cone] )
      cylinder( d1=98, d2=63, h=h_cone, center=false, $fn=300 );
  }
    
  // actual mounting flange with bevel
  difference() {
    color( "silver" ) 
    union() {
      // beveled upper flange
      translate( [0,0,-h_top] )
        cylinder( d=d_flange, h=h_top-h_bevel, center=false, $fn=300 );    
      translate( [0,0,-h_bevel] )
        cylinder( d1=d_flange, d2=d_flange-2*h_bevel, h=h_bevel, center=false, $fn=300 );    
    }

    // beveled inner cutout
    translate( [0,0,-h_inner+eps] )
      cylinder( d=d_inner, h=h_inner, center=false, $fn=300 );   
    translate( [0,0,-h_bevel+eps] )
      cylinder( d1=d_inner, d2=d_inner+2*h_bevel, h=h_bevel, center=false, $fn=300 );   
    
    // four + three M6 bores, depth 6
    for( alpha=[45,90,135,180,225,270,315] ) {
      rotate( [0,0,alpha] ) translate( [d_screws/2,0,-l_screw_bore+eps] ) 
        cylinder( d=6.2, l_screw_bore, center=false, $fn=50 );
    } 

    // alignment pin bore
    rotate( [0,0,0] ) translate( [d_screws/2,0,-6.20+eps] ) 
      cylinder( d=6.00, h=6.20, center=false, $fn=100 );
  }
}


module lwr_distance_plate()
{
  hh = 10.0; d_outer = 63.0; d_screws = 50.0; d_inner = 30;
  l_screw_bore= 5.0;
  difference() {
    cylinder( d=d_outer, h=hh, center=false, $fn=300 );

    translate( [0,0,-eps] )
      cylinder( d=d_inner, h=hh+2*eps, center=false, $fn=300 );

    // four + three M6 through bores
    for( alpha=[45,90,135,180,225,270,315] ) {
      rotate( [0,0,alpha] ) translate( [d_screws/2,0,-eps] ) 
        cylinder( d=6.2, hh+2*eps, center=false, $fn=50 );
    } 

    // alignment pin through bore
    rotate( [0,0,0] ) translate( [d_screws/2,0,-eps] ) 
      cylinder( d=6.00, h=hh+2*eps, center=false, $fn=100 );

    // three radial cable channels (on bottom)
    for( alpha = [-67.5, -22.5, 22.5, 67.5] )
      rotate( [0,0,alpha] ) translate( [d_outer/2,0,-eps] ) 
        rotate( [0,90,0] ) 
          cylinder( d=6, h=d_outer, center=true, $fn=50 );

    // +x "notch" (only in model)
    translate( [d_outer/2, 0, -eps] )
      cylinder( d=2.0, h=hh+2*eps, center=false, $fn=20 );
  }
} // lwr_distance_plate


/**
 * Model of our universal "TAMS LWR" tool flange adapter.
 * Outer diameter of 80mm is chosen to be compatible with 
 * the Mitsubishi PA10-6C robot flange (which is slightly larger 
 * in diameter than UR5/UR10/LWR4+/Diana/...).
 * 
 * Optional, we add h_base mm of height to the adapter to make space
 * for the radial (inside-to-outside) cable channels in the original
 * Kuka ("media interface") distance plate.
 *
 * 2023.07.03 created
 */
module lwr_tams_flange_adapter(
  d_outer  = 80.0,  // adapter plate outer diameter
  d_screws = 50.0, // diameter of mounting screws positions
  d_inner  = 35.0, // diameter of inner wire-through hole (Kuka only has 28)
  h_base   =  0.0, // optional extra base height for cable passthroughs
  h_core   = 12.0, // effective "TAMS" plate thickness
  make_screws = false,   // include fake screws
  extra_cavities = [[0], 25.0, 11, 6],   // [[angles], r_outer, d_cavity, h_cavity]
  // extra_cavities = [[0,90,180,270], 28.8, 10, 7],
) 
{
  M6 = 6.2;
  screw_inner_diameter = M6;
  screw_head_diameter = 2*M6; 

  n_outer_drill_holes = 8;
  
  //color( [0.8,0.7,0.6] )
  difference() {
    // actual adapter plate
    cylinder( d=d_outer, h=h_base+h_core, center=false, $fn=200 );
    
    // inner boring for tools and wires
    translate( [0, 0, -eps] )
      cylinder( d=d_inner, h=h_base+h_core+2*eps, center=false, $fn=100 );    

    // four+three LWR mounting screws M6, thread depth 5.0, 
    // countersunk screws DIN 7991 lengths are 8 10 12 14 16 18 20 ... 
    // at plate height 5+12 we can have l=16mm
    // 
    for( alpha=[45,90,135,180,225,270,315] ) {
      rotate( [0, 0, alpha] ) 
        translate( [d_screws/2, 0, h_core+h_base-7+3*eps] ) 
          rotate( [0, 180, 0] ) 
            screw_M6_10_countersunk( length=(10+h_base), extra_height=5 );
    }

    // LWR alignment pin bore
    translate( [d_screws/2, 0, -eps] )
      cylinder( d=6.0, h=h_base+h_core+2*eps, center=false, $fn=50 );
    
    // radial screws, eight M4 drill holes, diameter shrinks to the inside
    for( i=[0:1:(n_outer_drill_holes-1)] ) {      
      rotate( [0, 0, 22.5+i*360.0/n_outer_drill_holes] ) 
        translate( [d_outer/2, 0, h_base+h_core/2 ] ) 
          rotate( [0,-90,0] ) 
            cylinder( d1=4.2, d2=4.0, h=(d_outer-d_inner)/2+1, center=false, $fn=30 );
    }

    // three radial cable channels (on bottom)
    if (h_base > 0.0) {
      for( alpha = [-67.5, -22.5, 22.5, 67.5] )
        rotate( [0,0,alpha] ) translate( [d_outer/2,0, 1-eps] ) 
          rotate( [0,90,0] ) 
            cylinder( d=5.5, h=d_outer, center=true, $fn=50 );
     }

    // alignment notch at +x
    translate( [d_outer/2, 0, -eps] )
      cylinder( d=2.0, h=h_core+h_base+2*eps, center=false, $fn=50 );

    // optional axial cavities to fit next-state mounting plates
    if (len(extra_cavities) > 1) {
      angles = extra_cavities[0];
      echo( angles );
      nn = len(angles);
      rr = extra_cavities[1]; // radius to cavity
      dd = extra_cavities[2]; // cavity diameter
      zz = extra_cavities[3]; // cavity depth
      for( angle=angles ) {      
        rotate( [0, 0, angle] ) 
          translate( [rr, 0, h_base+h_core-zz ] ) 
            cylinder( h=zz+eps, d=dd, center=false, $fn=50 );
      }
    } // if
  }
} // lwr_tams_flange_adapter



module lwr_ati_nano_plate()
{
  M6 = 6.0;
  hh = 5;
  // ATi nano17e sensor diameter and length
  d_ati_nano17  = 17;     // diameter of ATi nano-17 sensor
  l_ati_nano17  = 14.5;   // body length of ATi nano-17 sensor
  
  difference() {
    // adapter plate for Kuka LWR
    // outer diameter 63mm
    cylinder( d=63, h=hh, center=false, $fn=300 );

    // one M6 "pass-stift" hole for exact alighment (unused by us), radial offset r=25
    translate( [25, 0, -eps] ) 
      cylinder(d=M6, h=hh+2*eps, $fn=100, center=false );
    
    // four M6 screw holes on LWR mounting plate, radial offset r=25 
    // r=25
    for( phi=[45, 135, 225, 315] ) {
      rotate( [0,0,phi] ) {
        translate( [25, 0, 1] ) 
          rotate( [180, 0, 0] )
            screw_M6_10_countersunk( length=10, extra_height=2+5 );
            // cylinder(d=M6, h=hh+2*eps, $fn=$fn, center=false );
      }
    } 
    translate( [0,0,-eps] ) cylinder( d=d_ati_nano17, h=hh+2*eps, center=false, $fn=100 );  
  }
  
  ati_nano17e_base_mounting_plate( h=hh, inbus=false, inbus_head_height=hh-2 );
}



module screw_M6_10_countersunk( length=10, extra_height=3 ) {
  M6 = 5.5;   // actual thread diameter
  dk = 11.5;  // outer head diameter
  k  = 3.0;   // head height
  // standard rim length seems to be 1 mm on M6
  union() {
    translate( [0,0,-k-extra_height+eps] ) cylinder( d=dk+0.5, h=extra_height, center=false, $fn=$fn );
    translate( [0,0,-k] ) cylinder( r1=dk/2, r2=M6/2, h=k, center=false, $fn=$fn );
    translate( [0,0,-eps] ) cylinder( d=M6, h=length, center=false, $fn=$fn );
  }
}


module wsg_50_finger_carrier( sgn=+1, color="blue" )
{
  // cube 9x30x24 + 9x30x9
  color( color )
  translate( [4.5*sgn, 0, 24/2] )
    cube( [9,30,24], center=true );
  color( color )
  translate( [-4.5*sgn, 0, 9/2] )
    cube( [9,30,9], center=true );
}


module wsg_50_gripper( 
  opening=11, // current finger distance 0<=opening<=110
)
{
  difference() {
    union() {
      // main body
      color( "silver", 0.8 )
      hull() {
        // offsets shifted by +/-0.5 mm due to cube size
        dx = [-72.5, -72.5, 72.5, 72.5, 72.5-21.0];
        dz = [  0.5,  72.0, 72.0, 21.0, 0.5 ];
        for( i=[0:4] ) {
          translate( [dx[i], 0, dz[i]] )
            cube( [1,50,1], center=true );
        }  
      } // hull

      color( "black" )
      translate( [-73.0, (25-37.5), 9] ) rotate( [0,-90,0] ) 
        cylinder( d=10, h=10, center=false, $fn=50 );

      color( "black" )
      translate( [-73.0, (25-10.5), 8] ) rotate( [0,-90,0] ) 
        cylinder( d=6, h=4, center=false, $fn=50 );

      color( "black" )
      translate( [-73.0, (25-22.5), 8] ) rotate( [0,-90,0] ) 
        cylinder( d=6, h=4, center=false, $fn=50 );
    } // union
 
    // screw holes, M3 depth 6
    sxx = [ -73+11, -73+121 ];
    syy = [ -42/2, 42/2 ];
    for( dx=sxx )
      for( dy=syy )
        translate( [dx, dy, -eps] )
          cylinder( d=3.2, h=6.0, center=false, $fn=30 );
  }

  // gripper fingers (finger carriers)
  translate( [-opening/2-9, 0, 72.6] )
      wsg_50_finger_carrier( sgn=+1 );
  translate( [+opening/2+9, 0, 72.6] )
      wsg_50_finger_carrier( sgn=-1 );
}



/**
 * simplified model of the current (flat, fixed) adapter plate
 * between Kuka LWR#1 and the Schunk WSG-50 gripper in our lab.
 */
module lwr_wsg50_mount_plate()
{
  sx_wsg50 = 146; sy_wsg50 = 50; hh = 6.0;
  sx_base  = 125;
  // cube( [sx_wsg50, sy_wsg50, 1], center=true );
  difference() {
    translate( [(sx_base-sx_wsg50)/2, 0, hh/2] ) 
    cube( [sx_base, 50, hh], center=true );

    // screw holes, M3 depth 6
    sxx = [ -73+11, -73+121 ];
    syy = [ -42/2, 42/2 ];
    for( dx=sxx )
      for( dy=syy )
        translate( [dx, dy, -eps] )
          cylinder( d=3.2, h=hh+2*eps, center=false, $fn=30 );

    // screw holes, M6 countersunk for Kuka LWR flange
    for( phi=[45, 135, 225, 315] ) {
      rotate( [0,0,phi] ) {
        translate( [25, 0, 3+eps] ) 
          rotate( [180, 0, 0] )
            screw_M6_10_countersunk( length=10, extra_height=0 );
            // cylinder(d=M6, h=hh+2*eps, $fn=$fn, center=false );
      }
    } // for 4 LWR flange screws

    // center alignment hole
    translate( [0,0,-eps] ) 
    cylinder( d=2, h=hh+2*eps, center=false, $fn=30 );
  }
}



/**
 * Outer "TAMS flange" adapter (core 80x12) for a Schunk WSG-50 gripper.
 * Cable passthrough (3x d=5mm) is routed on the top of the core.
 */
module tams_wsg50_adapter(
  d_outer = 90.0,
  d_core = 80.0, h_core = 12.0,
  d_inner = 30.0, 
  h_wsg_plate = 6.0, 
  cable_cavities = [],
  countersunk = 1,
)
{
  // Outer "TAMS mount" adapter for 80x12 mm size core, 
  // 8 radial screws DIN 7991 (countersunk inbus) size M4x30.
  // 
  sx_wsg50 = 146; sy_wsg50 = 50; 
  sx_base  = 125;
  hh = h_wsg_plate;

  // color( "lightgreen", 0.8 )
  difference() {
    union() {
      // main cylindrical adapter
      cylinder( d=d_outer, h=h_core+h_wsg_plate, center=false, $fn=300 );

      // WSG-50 mounting plate
      translate( [(sx_base-sx_wsg50)/2, 0, h_core+hh/2] ) 
        cube( [sx_base, 50, hh], center=true );
    }
    
    // outer hull of tams_flange adapter, h=h_tams, minus alignment notch
    difference() {
      translate( [0,0,-eps] )
        cylinder( d=d_core, h=h_core+2*eps, center=false, $fn=300 );
      translate( [d_core/2,0,-eps] )
        cylinder( d=2, h=h_core+2*eps, center=false, $fn=300 );
    }

    // inner hole
    translate( [0,0,-eps] )
      cylinder( d=d_inner+30, h=h_core+h_wsg_plate+2*eps, center=false, $fn=50 );

    // big cable passthrough hole (to "long" end)
    translate( [-30,0,h_core+hh/2] )
      cube( [60,20,hh+eps], center=true );

    // sideways cable passthrough
    translate( [0,0,h_core+hh-1] ) 
      rotate( [0,90,90] )
        cylinder( d=5.0, h=d_outer+eps, center=true, $fn=30 );

    // outer notch to indicate 0 position
    translate( [d_outer/2,0,-eps] )
      cylinder( d=2, h=h_core+h_wsg_plate+2*eps, center=false, $fn=50 );

    // radial bores for countersunk hex M4 mounting screws
    for( i=[0:7] ) {
      rotate( [0,0,i*45+22.5] )
        translate( [d_outer/2, 0, h_core/2] )
          rotate( [0,-90,0] )
            cylinder( d=4.2, h=(d_outer-d_core)/2+1, center=false, $fn=50 );
     if (countersunk) { // M4 countersunk head
        rotate( [0,0,i*45+22.5] )
          translate( [d_outer/2, 0, h_core/2] )
            rotate( [0,-90,0] )
              cylinder( d2=4.2, d1=8.2, h=2, center=false, $fn=50 );
      }
    }

    // screw holes, M3 depth 6
    sxx = [ -73+11, -73+121 ];
    syy = [ -42/2, 42/2 ];
    for( dx=sxx )
      for( dy=syy )
        translate( [dx, dy, h_core-eps] )
          cylinder( d=3.2, h=hh+2*eps, center=false, $fn=30 );

  } // difference
}



