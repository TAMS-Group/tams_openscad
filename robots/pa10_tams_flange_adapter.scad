/** pa10_flange.scad
 * 
 * Simplified models of the Mitsubishi PA10-6C tool mounting flange.
 *
 * 2023.06.29 - created
 *
 * (c) 2023, fnh, hendrich@informatik.uni-hamburg.de
 */
  
// note: expects the robot STLs in the robots/ subdirectory 

eps = 0.01;
ffn  = 150;
fdm_fudge = 0.2; // extra size for bores/holes/nuts due to shrinkage
ee = 0;          // explosion distance between adapter plane and robot STLs


zwrist  =  70.6; // 70.6 = pa10 tool plate offset from axis 5
yaw     =  0; // 33; //    0+7;
pitch   =  0; // -73; // -90+5;

make_holes     = true;  // set to false to export the collision mesh
make_pa10_s2w1 = true;


translate( [0,0,0 + 1*ee] ) pa10_tams_flange_adapter();



if (make_pa10_s2w1) {
  // pa10 wrist module extends 70mm from axes-crossing, 
  // mesh looks shifted by 2mm from z-axis...
  translate( [-2,0,-zwrist] ) 
    rotate( [0,-90+pitch,0] ) 
      color( "white" )
        import( "pa10w1.stl", convexity=5 );
  translate( [0,0,-260] ) 
    rotate( [0,-90,0] ) 
      color( "white" )
        import( "pa10e2.stl", convexity=5 );
}

 

/**
 * "TAMS standard" adapter plate to mount tools onto a 
 * Mitsubishi MHI PA10-6C robot,
 * using four drill-holes for M6 countersunk screws, depth 6.
 * The plate has a circular set of 8 radial M4 screw drill holes 
 * to connect along z-axis to other plates.
 */
module pa10_tams_flange_adapter( 
  d_outer  = 80.0,  // adapter plate outer diameter
  d_screws = 63.0, // diameter of mounting screws positions
  d_inner  = 40.0,  // diameter of inner wire-through hole
  hh       = 12.0, // total plate thickness
  make_screws = false,   // include fake screws
  // extra_cavities = [],   // [[angles], r_outer, d_cavity, h_cavity]
  extra_cavities = [[0,90,180,270], 28.8, 10, 7],
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

    // PA-10 countersunk screws, four M6 drill holes
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


module screw_M5( length=10, head_length=3, head_diameter=8.5,
                 washer_thickness=1, washer_diameter=11.0 ) {
  r = 2.6; eps=0.1;
  union() {
    cylinder( d=head_diameter, h=head_length+eps, center=false, $fn=20 ); 
    translate( [0,0,head_length] ) cylinder( r=r, h=length, center=false, $fn=20 );
    translate( [0,0,head_length] ) cylinder( d=washer_diameter, h=washer_thickness, center=false, $fn=20 );
  }
}

// end    
