/** biotac.scad - very rough 3D model of the Syntouch Biotac sensor.
 *
 * 05.07.23 - split into separate file
 * 01.06.22 - move plectrum to front (not back) of biotac sensor
 * 21.04.22 - created
 *
 * (c) 2022 fnh, hendrich@informatik.uni-hamburg.de
 */

eps = 0.1;

//color( "orange", 0.3 ) biotac_mesh();
//biotac_model( alpha=0.7 );

translate( [0, 40, 0] ) {
biotac_model( alpha=0.2, make_bone=true, make_cover=false );
color( "orange", 0.3 ) biotac_mesh();
}

/**
 * Syntouch/Shadow mesh of the original (capsule-shape) Biotac sensor,
 * with the origin at the base of the sensor part and aligned towards
 * +z axis.
 */
module biotac_mesh() {
  translate( [0.37,-7.6,-22.5] ) 
    rotate( [-20,0,0] ) scale( 25.4 )
      import( "biotac_decimated.stl" );
}



/**
 * Simplified approximated geometric model of the Biotac sensor,
 * with the origina at the base of the sensing part and aligned
 * towards +z axis.
 */
module biotac_model( make_base=true, make_bone=false, make_cover=true, alpha=1.0 ) {

  if (make_bone) { // approximated inner bone for mounting green cover
    // color( "gray", 1 )
    difference() {
      hull() {
        scale( [1.08,1.0,1.0] ) 
          cylinder( d=8.0, h=21, center=false, $fn=100 );
        translate( [0,0,21.5] ) 
          scale( [1.0,1.0,1.0] ) 
            sphere( d=9.0, $fn=100 );

       color( "red", 1 )
         translate( [0, 3, 10.7] ) 
            cube( [7,4,21], center=true );
      } // hull

      // 2x M2 screw bores
      for( dz = [ 9.4, 9.4+11.5 ] ) 
        translate( [0,6,dz] ) 
          rotate( [90,0,0] ) 
            cylinder( d=1.8, h=7, center=true, $fn=50 );
    }
  }

  if (make_cover)  // green part with white
  union() { // capsule-shaped sensing part
    color( "green", alpha )
    scale( [1.08,1.0,1.0] ) 
      cylinder( d=13.0, h=21, center=false, $fn=100 );

    color( "green", alpha )
    translate( [0,0,21.5] ) 
      scale( [1.08,1.0,1.0] ) 
        sphere( d=13.0, $fn=100 );

    color( "white", alpha )
    translate( [0,5.5,15.7] ) 
      cube( [10.7,5,21], center=true );
  }


  if (make_base) { // also approximate the mounting part
    color( "black", alpha )
    intersection() {
      translate( [0,-6.9,-22.6] ) 
        rotate( [-21,0,0] )
      { 
        intersection() {
          cylinder( d=15.9, h=25, center=false, $fn=100 );

          translate( [0,-2.99, 12.4] ) 
            cube( [18,16,25], center=true );
        } // intersection
      } // translate

      translate( [0,0,-15] ) cube( [18,30,30], center=true );
    } // intersction
  }
}
