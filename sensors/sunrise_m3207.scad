/** sunrise_m3207.scad
 * 
 * Simplified mechanical model of the Sunrise Instruments M3207
 * 6-axis force/torque sensor.
 *
 * 2023.07.19 - outer adapter with d=97 to better fit PA10-6C
 * 2023.07.19 - fix d_screws=28.28*2
 * 2023.07.19 - add 45 deg rotation to outer, to fit sensor +x with notch
 * 2023.07.16 - update with countersunk screws
 * 2023.06.29 - created
 *
 * (c) 2023, fnh, hendrich@informatik.uni-hamburg.de
 */
  
use <../robots/pa10_tams_flange_adapter.scad>


ee = 15; // explosion distance
eps = 0.01;
ffn  = 150;
fdm_fudge = 0.2; // extra size for bores/holes/nuts due to shrinkage


make_pa10_tams_flange_adapter = false; // pa10-6c -> core
make_m3207_outer_adapter = true;   // outer -> m3207 base
make_m3207 = false;                  // m3207 sensor
make_m3207_core_adapter = false;     // m3207 tool -> core

if (make_pa10_tams_flange_adapter) 
  color( "gray", 0.5 ) 
    translate( [0,0,-ee+eps] ) pa10_tams_flange_adapter();

if (make_m3207) 
  color( "lightblue" ) 
    translate( [0, 0, 12+4 + ee] ) sunrise_M3207();

if (make_m3207_outer_adapter) 
  translate( [0,0,0] ) 
    tams_m3207_outer_adapter();

if (make_m3207_core_adapter)
  translate( [0,0,0 + 12+4 + 17 + 3*ee] ) 
    tams_m3207_core_adapter();



module tams_m3207_outer_adapter( 
  d_outer = 97.0,      // total outer diameter
  d_tams = 80.1,       // outer diameter of tams adapter flange
  d_inner = 40.0,
  h_tams = 12.0,       // height of tams adapter flange
  h_m3207 = 4.0,
  d_m3207_screws = 28.28*2, // screws are at x,y=[-20,+20]
  countersunk = true,
) 
{

  color( "gold", 0.8 )
  difference() {
    cylinder( d=d_outer, h=h_tams+h_m3207, center=false, $fn=300 );
    
    // outer hull of tams_flange adapter, h=h_tams, minus alignment notch
    difference() {
      translate( [0,0,-eps] )
        cylinder( d=d_tams, h=h_tams+2*eps, center=false, $fn=300 );
      translate( [d_tams/2,0,-eps] )
        cylinder( d=2, h=h_tams+2*eps, center=false, $fn=300 );
    }

    // outer notch to indicate 0 position
    translate( [d_outer/2,0,-eps] )
      cylinder( d=2, h=h_tams+h_m3207+2*eps, center=false, $fn=50 );

    // radial bores for countersunk hex M4 mounting screws
    for( i=[0:7] ) {
      rotate( [0,0,i*45+22.5] )
        translate( [d_outer/2, 0, h_tams/2] )
          rotate( [0,-90,0] )
            cylinder( d=4.2, h=(d_outer-d_tams)/2+1, center=false, $fn=50 );
     if (countersunk) { // M4 countersunk head
        rotate( [0,0,i*45+22.5] )
          translate( [d_outer/2+eps, 0, h_tams/2] )
            rotate( [0,-90,0] )
              cylinder( d2=4.2, d1=8.2, h=2, center=false, $fn=50 );
      }
    }

    // axial bores for M3207 mounting screws (M4), depth 4mm
    for( i=[0:3] ) {
      rotate( [0,0,i*90+45] )
        translate( [d_m3207_screws/2, 0, h_tams/2-eps] )
          cylinder( d=4.2, h=h_m3207+2*eps+50, center=false, $fn=50 );
    }

    // central cable bore
    translate( [0,0,h_tams-eps] )
      cylinder( d=d_inner, h=h_tams+h_m3207+2*eps, center=false, $fn=50 );
    
  } // difference
} // tams_flange_m3207_adapter





/**
 * "TAMS standard" tool-side adapter for the Sunrise M3207 FT sensor.
 * This adapter plate can then be combined with other TAMS-like
 * modules.
 */
module tams_m3207_core_adapter(
  d_outer  = 80.0,   // adapter plate outer diameter
  d_screws = 57.6,   // diameter of mounting screws positions 28.8*2
  d_inner  = 40.0,   // diameter of inner wire-through hole
  hh       = 12.0, // total plate thickness
  make_screws = false,   // include fake screws
  // extra_cavities = [],   // [[angles], r_outer, d_cavity, h_cavity]
  extra_cavities = [[0,90,180,270], 28.8, 10, 7],
) 
{
  h2 =  4.0;   // M6 screws Senkkopf height
  h3 =  4.0;   // M4 screws head plus washer height
 
  screw_M4_diameter = 4.2;
  screw_M4_head_diameter = 7; 
  screw_M4_head_height = 4;

  n_m3207_drill_holes = 4;
  
  n_outer_drill_holes = 8;
  
  //color( [0.8,0.7,0.6] )
  difference() {
    // actual adapter plate
    cylinder( d=d_outer, h=hh, center=false, $fn=200 );
    
    // inner boring for tools and wires
    translate( [0, 0, -eps] )
      cylinder( d=d_inner, h=hh+2*eps, center=false, $fn=100 );    

    // four M4 screw holes to Sunrise tool side, depth M4
   for( i=[0:1:(n_m3207_drill_holes-1)] ) {      
      rotate( [0, 0, i*360.0/n_m3207_drill_holes+45] ) {
        // through bore M4 thread
        translate( [d_screws/2, 0, -eps ] ) 
          cylinder( d=4.2, h=hh+2*eps, center=false, $fn=30 );
        // DIN 912 M4x10mm hex screw head cavity, so that depth=4
        translate( [d_screws/2, 0, hh-6-eps ] ) 
          cylinder( d=screw_M4_head_diameter+1, 
                    h=screw_M4_head_height+10,
                    center=false, $fn=30 );
      }
    }
    
    // radial screws, eight M3 drill holes, diameter shrinks to the inside
    for( i=[0:1:(n_outer_drill_holes-1)] ) {      
      rotate( [0, 0, 22.5+i*360.0/n_outer_drill_holes] ) 
        translate( [d_outer/2, 0, hh/2 ] ) 
          rotate( [0,-90,0] ) 
            cylinder( d1=4.2, d2=4.0, h=(d_outer-d_inner)/2+1, center=false, $fn=30 );
    }

    // alignment notch at +x
    translate( [d_outer/2, 0, -eps] )
      cylinder( d=2.0, h=hh+2*eps, center=false, $fn=50 );

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
} // tams_m3207_core_adapter



module sunrise_M3207_hand_adapter( dd = 74.0, hh = 10.0, d2 = 20.0 ) 
{
  // dd = 74.0; // M3207 outer diameter
  // diameter of central core bore, can be zero
  eps = 0.1;
  
  n_m3207_drill_holes = 4;
  r_m3207_drill_holes = 28.28;
  
  rotate( [0,0,45] )
  translate( [0,0,0] ) 
  difference() {
    cylinder( d=dd, h=hh, center=false, $fn=ffn ); 
      translate( [0, 0, -1.5*eps] ) cylinder( d=d2, h=hh+2*eps, center=false, $fn=50 );     
    
    // M3207 screws, four M4 drill holes
    if (make_holes)
    for( i=[0:1:(n_m3207_drill_holes-1)] ) {      
      rotate( [0, 180, i*360.0/n_m3207_drill_holes] ) 
        translate( [r_m3207_drill_holes, 0, -hh-eps ] ) 
          screw_M4( length=hh );
    }
  }
} // sunrise_M3207_hand_adapter



module hand_base_adapter( dd = 74.0, hh = 15.0, d2 = 40.0 ) 
{
  n_hand_drill_holes = 4;
  r_hand_drill_holes = 28.28;
  eps = 0.1;
  
  rotate( [0,0,45] )
  translate( [0,0,0] ) 
  difference() {
    cylinder( d=dd, h=hh, center=false, $fn=ffn ); 
      translate( [0, 0, -1.5*eps] ) cylinder( d=d2, h=hh+2*eps, center=false, $fn=50 );     
    
    // M3207 screws, four M4 drill holes
    if (make_holes)
    for( i=[0:1:(n_hand_drill_holes-1)] ) {      
      rotate( [0, 0, i*360.0/n_hand_drill_holes] ) 
        translate( [r_hand_drill_holes, 0, -eps ] ) 
          screw_M4( length=hh );
    }
  }
}


// SCAD module of the Sunrise SAST type M3207 force-torque sensor:
// outer diameter 74 mm,
// inner diameter 40 mm,
// thickness 17 mm overall, neutral axis at z=8.6,
// base thickness 11 mm, spacing 1 mm, tool-part thickness 5 mm
//
// four screw holes M4 on base and tool plate with radius 28.28 mm,
// two alignment holes (4 and 3 mm diameter) between the screw holes,
// x and y axis centered between the screw holes,
// y along (3 -> 4 mm alignment boring), 
// z pointing up from base (thin) to tool (thick) cylinder
// 
// load capacity 130N for x and y, 400N for z, 10Nm for tx, ty, tz.
//
module sunrise_M3207( make_holes=true ) 
{
  h1 = 5.0;    // thin body part
  h2 = 11.0;   // thick body part
  h3 = 1.0;    // spacing
  r1 = 74.0/2; // outer
  r2 = 40.0/2; // inner
  
  union() {
    color( [0.8,0.8,0.8] )
    translate( [0, 0, h1/2] ) {
      // thin base part (in x-y plane, oriented to -z)
      difference() {
        // outer cylinder minus 40mm diameter inner hole
        cylinder( h=h1,   r=r1, center=true, $fn=ffn );
        cylinder( h=h1+1, r=r2, center=true, $fn=ffn );

        // four M4 screw borings
        translate( [-20, -20, 0] ) cylinder( h=5.5, r=2.0, center=true, $fn=20 );
        translate( [-20, +20, 0] ) cylinder( h=5.5, r=2.0, center=true, $fn=20 );
        translate( [+20, -20, 0] ) cylinder( h=5.5, r=2.0, center=true, $fn=20 );
        translate( [+20, +20, 0] ) cylinder( h=5.5, r=2.0, center=true, $fn=20 );
        
        // alignment pin borings
        translate( [-28.28, 0, -h1/2-0.01] ) cylinder( h=3.5, r=1.5, center=false, $fn=20 );
        translate( [ 28.28, 0, -h1/2-0.01] ) cylinder( h=3.5, r=2.0, center=false, $fn=20 );
        
      } // thin base part
    }

    // thick tool part (in x-y plane, oriented to +z)
    translate( [0, 0, (h1+h2/2+h3)] ) {
      color( [0.8,0.8,0.8] )
      difference() {
        // outer cylinder minus 40mm diameter inner hole
        cylinder( h=h2,   r=r1, center=true, $fn=ffn );
        cylinder( h=h2+1, r=r2, center=true, $fn=ffn );

        if (make_holes) {
          // four M4 screw borings
          translate( [-20, -20, 0] ) cylinder( h=12.0, r=2.0, center=true, $fn=20 );
          translate( [-20, +20, 0] ) cylinder( h=12.0, r=2.0, center=true, $fn=20 );
          translate( [+20, -20, 0] ) cylinder( h=12.0, r=2.0, center=true, $fn=20 );
          translate( [+20, +20, 0] ) cylinder( h=12.0, r=2.0, center=true, $fn=20 );
        
          // alignment pin borings
          translate( [-28.28, 0, h2/2-3.49] ) cylinder( h=3.5, r=1.5, center=false, $fn=20 );
          translate( [ 28.28, 0, h2/2-3.49] ) cylinder( h=3.5, r=2.0, center=false, $fn=20 );
        }
      } // thick tool part
    }
  } // M3207 union
}


module screw_M4( length=10, head_length=3, head_diameter=7,
                 washer_thickness=0, washer_diameter=10 ) {
  r = 2.1; eps=0.1;
  union() {
    cylinder( d=head_diameter, h=head_length+eps, center=false, $fn=20 ); 
    translate( [0,0,head_length] ) cylinder( r=r, h=length, center=false, $fn=20 );
    translate( [0,0,head_length] ) cylinder( d=washer_diameter, h=washer_thickness, center=false, $fn=20 );
  }
}


module nut_M4( diameter=8.1, height=2.5 ) {
  cylinder( d=diameter, h=height, $fn=6, center=false );
}


module nut_M5( diameter=9.0, height=4.0 ) {
  cylinder( d=diameter, h=height, $fn=6, center=false );
}


module screw_M5( length=10, head_length=3, head_diameter=8.5,
                 washer_thickness=1, washer_diameter=11.0 ) {
  r = 2.6; eps=0.1;
  union() {
    cylinder( d=head_diameter, h=head_length+eps, center=false, $fn=20 ); 
    translate( [0,0,head_length] ) cylinder( r=r, h=length, center=false, $fn=20 );
    translate( [0,0,head_length] ) cylinder( d=washer_diameter, h=washer_thickness, center=false, $fn=20 );
  }
}



module gray04() {
  if (use_colors) color( [0.3,0.3,0.3] ) children();
  else children();
}

module gray05() {
  if (use_colors) color( [0.5,0.5,0.5] ) children();
  else children();
}

module gray06() {
  if (use_colors) color( [0.7,0.7,0.7] ) children();
  else children();
}

module gray08() {
  if (use_colors) color( [0.8,0.8,0.8] ) children();
  else children();
}

module red06() {
  if (use_colors) color( [0.8,0.3,0.3] ) children();
  else children();
}
    
