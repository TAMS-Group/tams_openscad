/** tams_flange_outer_adapter.scad 
 * 
 * Generic "TAMS flange" adapter, to be modified for mounting  
 * specific grippers/tools/attachments to a robot with a TAMS core adapter.
 *
 */

$fn = 100;
eps = 0.1;
ee = 30;   // "explosion" distance, use 0 for STL export


translate( [0,0,ee] ) tams_flange_outer_adapter();
translate( [0,0,0] ) iso9409_flange_outer_adapter();





module tams_flange_outer_adapter(
  d_outer = 99.0,      // total outer diameter
  d_tams = 80.1,       // outer diameter of tams adapter flange
  d_inner = 40.0,
  h_core = 12.0,       // height of tams adapter flange, typically 12 mm
  h_upper = 4.0,       // height of upper part, e.g. 4.0mm circular plate
  upper_screws = [],    // [[angles], radius, bore]: axial through bores
  countersunk = true,
)
{
  color( "gold", 0.8 )
  difference() {
    cylinder( d=d_outer, h=h_core+h_upper, center=false, $fn=300 );

    // outer hull of tams_flange adapter, h=h_core, minus alignment notch
    difference() {
      translate( [0,0,-eps] )
        cylinder( d=d_tams, h=h_core+2*eps, center=false, $fn=300 );
      translate( [d_tams/2,0,-eps] )
        cylinder( d=2, h=h_core+2*eps, center=false, $fn=300 );
    }

    // outer notch to indicate 0 position
    translate( [d_outer/2,0,-eps] )
      cylinder( d=2, h=h_core+h_upper+2*eps, center=false, $fn=50 );

    // radial bores for (countersunk) hex M4 mounting screws
    for( i=[0:7] ) {
      rotate( [0,0,i*45+22.5] )
        translate( [d_outer/2, 0, h_core/2] )
          rotate( [0,-90,0] )
            cylinder( d=4.2, h=(d_outer-d_tams)/2+1, center=false, $fn=50 );
     if (countersunk) { // M4 countersunk head
        rotate( [0,0,i*45+22.5] )
          translate( [d_outer/2+eps, 0, h_core/2] )
            rotate( [0,-90,0] )
              cylinder( d2=4.2, d1=8.2, h=2, center=false, $fn=50 );
      }
    }

    // central cable bore
    if (d_inner > 0) {
      translate( [0,0,h_core-eps] )
        cylinder( d=d_inner, h=h_core+h_upper+2*eps, center=false, $fn=300 );
    }

    // if upper part screws are specified: use given diameter and angles
    if (len(upper_screws) > 0) {
      angles = upper_screws[0];
      radius = upper_screws[1];
      bore   = upper_screws[2];
      for( angle = angles )
        rotate( [0,0,angle] )
          translate( [radius, 0, h_core-eps] )
            cylinder( d=bore, h=h_upper+2*eps, center=false, $fn=50 );
    }
  } // difference
} // tams_flange_outer_adapter


/**
 * variant of "TAMS flange" outer adapter that provides a ISO9409 
 * mounting flange, with 6mm dovel pin and four r=25mm M6 screws.
 * We use standard M6 hex nut to provide the threads.
 */
module iso9409_flange_outer_adapter(
  d_outer = 99,
  d_inner = 37, // UR5 has 40
  h_core  = 12, 
  h_upper = 10,
)
{
  
  hh = h_core + h_upper;

  difference() {
    tams_flange_outer_adapter(
      d_outer = d_outer,    // total outer diameter
      d_tams  = 80.1,       // outer diameter of tams adapter flange
      d_inner = d_inner,
      h_core  = h_core,    // height of tams adapter flange, typically 12 mm
      h_upper = h_upper,   // height of upper part, e.g. 4.0mm circular plate
      upper_screws = [],   // [[angles], radius, bore]: axial through bores
      countersunk = true
    );

    // inner boring for tools and wires
    translate( [0, 0, -eps] )
      cylinder( d=d_inner, h=hh+2*eps, center=false, $fn=100 ); 

    // four M6 bores, depth 6, and M6 nut cavities. 
    // Standard DIN 934 / ISO 4033 M6 nut measures edge size 10.89 height 5.0.
    // 
    d_screws = 50.0; 
    for( alpha=[0,90,180,270] ) {
      rotate( [0,0,alpha+45] ) 
        translate( [d_screws/2,0,h_core-eps] ) 
          cylinder( d=6.2, h_upper+2*eps, center=false, $fn=50 );
      rotate( [0,0,alpha+45] ) 
        translate( [d_screws/2,0,h_core-eps] ) 
          rotate( [0,0,30] )  // yaw rotation to have nut side parallel to inner cutout
            cylinder( d=10.89, (5.0+1.0), center=false, $fn=6 );
    } 

    // alignment pin bore
    rotate( [0,0,0] ) translate( [d_screws/2,0, h_core-eps] ) 
      cylinder( d=6.00, h=h_upper*2*eps, center=false, $fn=100 );

    // flange alignment pin bore (angle=0), r=d_screws/2, d=6mm
    translate( [d_screws/2, 0, h_core-eps] )
      cylinder( d=6.0, h=h_upper+2*eps, center=false, $fn=100 );
  }
} // iso9409_flange_outer_adapter
