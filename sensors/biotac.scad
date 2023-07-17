/** biotac.scad - very rough 3D model of the Syntouch Biotac sensor.
 *
 * 05.07.23 - split into separate file
 * 01.06.22 - move plectrum to front (not back) of biotac sensor
 * 21.04.22 - created
 *
 * (c) 2022 fnh, hendrich@informatik.uni-hamburg.de
 */

eps = 0.1;

color( "orange", 0.3 ) biotac_mesh();
biotac_model( alpha=0.7 );


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
module biotac_model( make_base=true, alpha=1.0 ) {

  color( "green", alpha )
  union() { // capsule-shaped sensing part
    scale( [1.08,1.0,1.0] ) 
      cylinder( d=13.0, h=21, center=false, $fn=100 );

    translate( [0,0,21.5] ) 
      scale( [1.08,1.0,1.0] ) 
        sphere( d=13.0, $fn=100 );

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
