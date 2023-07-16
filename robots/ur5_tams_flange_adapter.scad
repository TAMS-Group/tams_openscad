 /** ur5_tams_flange_adapter.scad
 * 
 * Model of the universal "TAMS UR5" tool flange adapter.
 * Outer diameter of 80mm is chosen to be compatible with 
 * the Mitsubishi PA10-6C robot flange (slightly larger in
 * diameter than UR5/UR10/LWR4+/Diana/...).
 *
 * 2023.07.10 add nut_cavities for embedded square/hex nuts
 * 2023.07.02 created
 *
 * (c) 2023, fnh, hendrich@informatik.uni-hamburg.de
 */
  

use <ur5_flange.scad>
use <../sensors/sunrise_m3207.scad>
use <../libs/simple_screws.scad>

eps = 0.01;
ee = 40;


// translate( [0,0,0] ) ur5_alignment_pin_6x10();

//translate( [0,0,0] ) 
//  ur5_tams_flange_adapter( 
//    extra_cavities=[], 
//    nut_cavities=[4, 15, 9.99, 4.0, 0.0, 45] ); // M4 square nuts, "rear" insertion

// This did not 3D-print well: the inserted nuts tend to rotate in place
// when tightening the screws, disabling the part...
//translate( [0,0,ee] ) 
//  ur5_tams_flange_adapter( 
//    extra_cavities =[[0,90,180,270], 28.8, 10, 5], 
//    nut_cavities =[6, 17, 7.90, 3.4, 5.0, 0.0], // M4 hex nuts, top insertion
//    make_screws=true );

// printed ok, but the nuts are just a tiny bit too far inside for
// M4x30 screws when used with the 99mm diameter "outer" adapters.
// Maybe using a longer radius (e.g. 18 instead of 15) might be an option.
//
translate( [0,0,0.5*ee] ) 
  ur5_tams_flange_adapter( 
    extra_cavities =[[0,90,180,270], 28.8, 10, 5], 
    nut_cavities =[6, 15, 7.90, 3.4, 0.0, 30.0], // M4 hex nuts, top insertion
    make_screws=true );

translate( [0,0,0 - 0.4*ee] ) ur5_tool_flange();

color( "gray", 0.2 ) 
translate( [0,0,0 + 2*ee] ) tams_flange_sunrise_adapter();



module ur5_alignment_pin_6x10()
{
  cylinder( d=6.0, h=10.0, center=false, $fn=300 );
}

 

/**
 * "TAMS flange" core adapter plate to mount tools onto a 
 * Universal Robot UR5 robot,
 * using four drill-holes for M6 countersunk screws, depth 6,
 * aond one d=6.0mm H7 alignment pin.
 * The plate has a circular set of 8 radial M4 screw drill holes 
 * to connect along z-axis to other plates.
 */
module ur5_tams_flange_adapter( 
  d_outer  = 80.0,  // adapter plate outer diameter
  d_screws = 50.0, // diameter of mounting screws positions
  d_inner  = 31.5,  // diameter of inner wire-through hole
  hh       = 12.0, // total plate thickness
  make_screws = false,   // include fake screws
  // extra_cavities = [],   // [[angles], r_outer, d_cavity, h_cavity]
  extra_cavities = [[0,90,180,270], 28.8, 10, 7],
  // empty or "square" or "hex", inner radius to slot
  nut_cavities = [],
) 
{
  dd = 98.0;   // outer diameter of PA-10 flange 
 
  h2 =  4.0;   // M6 screws Senkkopf height
  h3 =  4.0;   // M4 screws head plus washer height
 
  M6 = 6.2;

  screw_inner_diameter = M6;
  screw_head_diameter = 2*M6; 

  n_pa10_drill_holes = 4;
  
  n_outer_drill_holes = 8;
  r_outer_drill_holes = dd/2;

  dz=20;
  
  //color( [0.8,0.7,0.6] )
  difference() {
    // actual adapter plate
    cylinder( d=d_outer, h=hh, center=false, $fn=200 );
    
    // inner boring for tools and wires
    translate( [0, 0, -eps] )
      cylinder( d=d_inner, h=hh+2*eps, center=false, $fn=100 );    

    // robot flange countersunk screws, four M6 drill holes
    for( i=[0:1:(n_pa10_drill_holes-1)] ) {      
      rotate( [0, 0, i*360.0/n_pa10_drill_holes+45] ) 
        rotate( [0, 180, 0] ) 
          translate( [d_screws/2, 0, -hh-1 ] ) 
            screw_M6_10_countersunk_extra_rim( length=(10+5*eps), extra_rim=4 );
    }
    
    // radial screws, eight M3 drill holes, diameter shrinks to the inside
    for( i=[0:1:(n_outer_drill_holes-1)] ) {      
      rotate( [0, 0, 22.5+i*360.0/n_outer_drill_holes] ) 
        translate( [d_outer/2, 0, hh/2 ] ) 
          rotate( [0,-90,0] ) 
            cylinder( d1=4.1, d2=3.9, h=(d_outer-d_inner)/2+1, center=false, $fn=30 );
    }

    // optional "nut cavities": n=4 or 6, r=position, d=diameter, 
    if (len(nut_cavities) > 0) {
      n_sides = nut_cavities[0]; // n=4: square or n=6: hex nuts
      r_slot  = nut_cavities[1]; // center distance (radius) to nuts 
      d_slot  = nut_cavities[2]; // diameter of SCAD cylinder for nut
      h_slot  = nut_cavities[3]; // length of nut cavity
      z_slot  = nut_cavities[4]; // optional z-height for "top open" insertion slot
      alpha   = nut_cavities[5]; // yaw-angle of nut
      
      for( i=[0:1:(n_outer_drill_holes-1)] ) {      
        rotate( [0, 0, 22.5+i*360.0/n_outer_drill_holes] ) 
          hull() {
            translate( [r_slot, 0, hh/2 ] ) 
              rotate( [0,90,0] ) 
                rotate( [0,0,alpha] )
                  cylinder( d=d_slot, h=h_slot, center=false, $fn=n_sides );
            translate( [r_slot, 0, hh/2+z_slot ] ) 
              rotate( [0,90,0] )
                rotate( [0,0,alpha] )
                  cylinder( d=d_slot, h=h_slot, center=false, $fn=n_sides );
          } // hull 
      }
    }

    // alignment notch at +x
    translate( [d_outer/2, 0, -eps] )
      cylinder( d=2.0, h=hh+2*eps, center=false, $fn=50 );

    // flange alignment pin bore (angle=0), r=d_screws/2, d=6mm
    translate( [d_screws/2, 0, -eps] )
      cylinder( d=6.0, h=hh+2*eps, center=false, $fn=100 );

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
          translate( [rr, 0, hh-zz ] ) 
            cylinder( h=zz+eps, d=dd, center=false, $fn=50 );
      }
    } // if
  }
}


module screw_M6_10_countersunk_extra_rim( length=10, extra_rim=3 ) {
  r = 3.1; rim = 1; eps=0.1; dr = 3; // head radius minus screw radius
  // standard rim length seems to be 1 mm on M6
  union() {
    cylinder(  r=r+dr, h=rim+extra_rim+2*eps, center=false, $fn=50 );
    translate( [0,0,rim+extra_rim+eps] )     cylinder( r1=r+dr, r2=r, h=3, center=false, $fn=50 );
    translate( [0,0,rim+extra_rim+dr] )       cylinder( r=r, h=length, center=false, $fn=50 );
  }
}


// end    
