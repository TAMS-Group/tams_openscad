/** robotiq_3finger_hand_adapter.scad 
 * 
 * Model of the mounting flange and outer "TAMS flange" for the
 * Robotiq adaptive 3-finger hand.
 * 
 *
 * Note: exact z-position of radial screw bores NOT specified by Robotiq;
 * need to measure the actual hand...
 * 
 * 13.07.2023 - created
 *
 * (c) 2023, fnh, hendrich@informatik.uni-hamburg.de
 */

$fn = 100;
eps = 0.1;
ee  = 30; // explosion distance
inch = 25.4;



translate( [0,0,0+2*ee] )  robotiq_3finger_hand_palm(); // mesh w/o screw bores

color( "lightgreen" )
translate( [0,0,1*ee] )  robotiq_3finger_hand_flange( outer_screws=[] ); // full flange specs

// shift down by 12mm (TAMS h_core height)
color( "green", 0.1 )
translate( [0,0,0*ee] ) 
  robotiq_3finger_outer_adapter(  ); 


/**
 * Mesh of the 3-finger hand palm (from Robotiq ROS package).
 * Centered in x and y, origin at bottom (z=0) of mounting flange.
 */
module robotiq_3finger_hand_palm() {
  // intersection() {
  {
    color( "gray" )
    translate( [0,0,53.98] ) rotate( [90,0,0] ) 
      scale( 1000 ) import( "robotiq_palm.stl" );
    // cylinder( d=200,h=0.01,center=true ); // for visual alignment only
  }
}


/**
 * OpenSCAD model of the "custom coupling" as specified in figure 6.6.3
 * in the Robotiq 3-finger hand manual.
 * Centered in x and y, origin at bottom (z=0) of mounting flange.
 *
 * Screws are specified as "6x6-32", which probably means
 * head screw UNC #6-32 stainless steel black oxidized 
 * (similar DIN 7991). Wrench size : 1/16" Diameter : 3,51 mm. Thread per inch: 32
 * Diameter: #6 (0,138") (3,505 mm) Length: 5/16" (approx. 7,94 mm) 3/8" 
 * Gewindedurchmesser: 3.50mm
 *
 * Note: z-height of tilted radial screw bores is NOT specified exactly,
 * looks to be at half of the inner core height at the inside of the inner
 * bore. Currently modeled as halfway height of the outer "step" between
 * outer flat plate and rising inner core, which may be wrong.
 */
module robotiq_3finger_hand_flange( 
  outer_screws=[40,9,25], // total length, head diameter, thread length
)
{
  d_outer = 3.15 * inch; // 80.00 mm
  d_inner  = 1.81 * inch; // 45.97 mm
  d_bore   = 1.00 * inch; // 25.40 mm
  d_dowel_pin = 2.50 * inch;
  h_outer = (0.5 - 0.375) * inch;
  h_inner = 0.5 * inch;

  difference() {
    union() {
      // outer and inner cylinder of the mounting flange
      translate( [0, 0, 0.375*inch] ) 
      cylinder( d=d_outer, h=h_outer, center=false, $fn=300 );
      cylinder( d=d_inner, h=h_inner, center=false, $fn=300 );

     // optional total screw length outside
     if (len(outer_screws) > 2) {
       for( iii=[0:5] )
         rotate( [0,0,60*iii] )
           translate( [d_inner/2, 0, 0.375*inch/2] )
             rotate( [0, 90+5, 0] ) translate( [0, 0, -1] ) 
               cylinder( d=3.70, h=outer_screws[0], center=false, $fn=30 );

       // optional total screw length outside
       for( iii=[0:5] )
         rotate( [0,0,60*iii] )
           translate( [d_inner/2, 0, 0.375*inch/2] )
             rotate( [0, 90+5, 0] ) translate( [0, 0, outer_screws[2]] ) 
               cylinder( d=outer_screws[1], h=outer_screws[0]-outer_screws[2], center=false, $fn=30 );
      } // if
    }

    // center bore
    translate( [0,0,-eps] )
    cylinder( d=d_bore, h=h_inner+2*eps, center=false, $fn=300 );

    // dowel pin d=0.1885*inch "3/16 slip fit"
    rotate( [0,0,15] ) 
    translate( [d_dowel_pin/2, 0, -eps] )
      cylinder( d=0.1885*inch, h=h_inner+2*eps, center=false, $fn=100 );

     // six mounting screw bores, 5-degrees tilted in yaw/pitch
     // into the hand
     if (len(outer_screws) == 0) {
       for( ii=[0:5] )
         rotate( [0,0,60*ii] )
           translate( [d_inner/2, 0, 0.375*inch/2] )
             rotate( [0, -180+90+5, 0] )
               cylinder( d=3.50, h=40, center=true, $fn=30 );
       }
  } // difference
}




/**
 * outer adapter for the Robotiq 3-finger hand.
 */
module robotiq_3finger_outer_adapter(
  d_outer = 99.0,      // total outer diameter
  d_tams = 80.1,       // outer diameter of tams adapter flange
  d_inner = 1.81*inch+eps, // sensor itself has only 9.38,
  d_dowel_pin = 2.5*inch,
  h_core = 12.0,       // height of tams adapter flange, typically 12 mm
  h_upper = 0.375*inch,       // height of upper part, e.g. 4.0mm circular plate
  h_inbus_head = 3.0,  // adjust so that 5mm screw thread "stick out"
  upper_screws = [],    // [[angles], radius, bore]: axial through bores
  countersunk = true,
)
{
  // color( "gold", 0.8 )
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

    // subtract Robotiq 3-finger hand flange with outside screws
    translate( [0,0,h_core+eps] ) 
      robotiq_3finger_hand_flange( outer_screws=[60,9,20] );

    // bore for dowel pin d=0.1885*inch "3/16 slip fit"
    rotate( [0,0,15] ) 
    translate( [d_dowel_pin/2, 0, h_core-eps] )
      cylinder( d=0.1885*inch, h=h_upper+2*eps, center=false, $fn=100 );


    // radial bores for (countersunk) hex M4 mounting screws
    for( i=[0:7] ) {
      rotate( [0,0,i*45+22.5] )
        translate( [d_outer/2, 0, h_core/2] )
          rotate( [0,-90,0] )
            cylinder( d=4.2, h=(d_outer-d_tams)/2+1, center=false, $fn=50 );

     if (countersunk) { // M4 countersunk head
        rotate( [0,0,i*45+22.5] )
          translate( [d_outer/2, 0, h_core/2] )
            rotate( [0,-90,0] )
              cylinder( d2=4.2, d1=8.2, h=2, center=false, $fn=50 );
        rotate( [0,0,i*45+22.5] )
          translate( [d_outer/2+2, 0, h_core/2] )
            rotate( [0,-90,0] )
              cylinder( d2=8.2, d1=8.2, h=2+eps, center=false, $fn=50 );
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

} // robotiq_3finger_outer_adapter


