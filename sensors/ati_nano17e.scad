/** ati_nano17e.scad - ATi nano17e F/T sensor
 *
 * 3D-model of the ATi nano17 (type e) six-axis F/T sensor
 * with matching mounting plates.
 *
 * The sensor is oriented below the z=0 plane, so that 
 * the sensing axes are aligned with the Openscad axes.
 * Dimensions are in millimeters; use an outer scale( 0.001 )
 * if you need meters (e.g., conversion to ROS URDF).
 *
 * The "nut_slot" variant is for 3D-printing a dummy sensor
 * with embedded M2 nuts (M2 threads in plastic are too fragile).
 *
 * 26.02.2017 - created, based on ATi datasheet 9230-05-1311.auto.pdf
 *
 * (C) 2017 fnh, hendrich@informatik.uni-hamburg.de
 */


eps=0.1; 
$fn = 100; 

m2          = 2.2;    // diameter of M2 screw thread
m2hex       = 4.0;    // diameter of M2 hex screw head (norm says: 3.8)
rs          = 12.5/2; // distance radius of screw centers from sensor z-axis

screw_depth = 3.5;    // depth of M2 screw holes
index_depth = 3.0;    // depth of d=2 index pins


translate( [0,0,14.5] )  ati_nano17e();
translate( [0,0,-1] ) ati_nano17e( nut_slots=true );

// translate( [50,0,1] ) ati_nano17e_tool_mounting_plate( h=4, inbus=true, inbus_head_height=2 );
// translate( [50,0,-14.5-1-4] ) ati_nano17e_base_mounting_plate( h=4, inbus=true, inbus_head_height=2 );



module ati_nano17e( nut_slots=false ) {
  total_height = 14.5;
  tool_part_height = 5.0; // guessed, not specified exactly
  bottom_part_height = total_height - tool_part_height - 0.5;


  cable_diameter = 5.3;
  cable_height   = 4; // cable_diameter + 2;
  cable_housing  = 15.5;
  cable_shield   = 17.5;

  difference() { 
    union() { 
      // main, "bottom" part of the sensor
      // 
      gray08() translate( [0,0,-total_height] ) cylinder( d=17.0, h=bottom_part_height, center=false );

      // shorter, "upper"/"tool" part of the sensor
      // 
      gray08() translate( [0,0,-tool_part_height] ) cylinder( d=17.0, h=tool_part_height, center=false );

      gray02() translate( [0,0,-tool_part_height-0.5] ) 
        cylinder( d=18.0-2, h=0.5+2*eps, center=false );


      // nane17e cable housing (simplified) 
      x = 7;
      gray07() 
        rotate( [0,0,45] ) 
          translate( [0,cable_housing/2, -total_height + cable_height] ) 
            cube( size=[x, cable_housing, x], center= true );

      // nano17e cable (simplified)
      //
      gray02()
        translate( [0,0,-total_height+cable_height] )
          rotate( [-90,0,45] ) 
            cylinder( d=cable_diameter, h=cable_housing+cable_shield, center=false );

      // more stuff 
    }


    // reference pins (d=2 depth=2) on the upper/toor part
    //
    rotate( [0,0,0] ) translate( [rs, 0, -index_depth] ) 
      cylinder( d=2.0, h=index_depth+eps, center=false );
    rotate( [0,0,120] ) translate( [rs, 0, -index_depth] ) 
      cylinder( d=2.0, h=index_depth+eps, center=false );

    // three screw holes on the upper/tool part of the sensor
    //
    for( phi=[0,120,240] ) {
      rotate( [0,0,phi+60] ) 
        translate( [rs, 0, -screw_depth] )
          cylinder( d=m2, h=screw_depth+eps, center=false );
    } 
    
    // three slots for M2 nuts, in case the object is used
    // as a mechanical dummy for mounting the actual sensor
    // DIN says: M2 nut height = 1.6mm, M2 e (diagonal) = 4.38mm
    if (nut_slots) {
      m2nut = 4.5;
      m2hhh = 2.0;
      for( phi=[0,120,240] ) {
        rotate( [0,0,phi+60] ) {
          translate( [rs, 0, -1-m2hhh] ) // 1mm flesh, nut height
            cylinder( d=m2nut, h=m2hhh, $fn=6, center=false );
          translate( [rs+2, 0, -1-m2hhh] )
            cylinder( d=m2nut, h=m2hhh, $fn=6, center=false );
        }
      } 
    }  // if nut_slots


    // three inner screws used by ATi to hold the sensor together
    //
    for( phi=[60,180,300] ) {
      rotate( [0,0,phi] ) {
        translate( [2.3, 0, -2] ) 
          cylinder(d=m2, h=2+eps, $fn=6, center=false );
        translate( [2.3, 0, -0.5] ) 
          cylinder( d=m2hex, h=0.5+eps, , center=false );
      }
    } 


    
    // reference pins (d=2 depth=2) on base/reference part
    //
    rotate( [0,0,5] ) translate( [rs, 0, -total_height-eps] ) 
      cylinder( d=2.0, h=index_depth+eps, center=false );
    rotate( [0,0,-120+5] ) translate( [rs, 0, -total_height-eps] ) 
      cylinder( d=2.0, h=index_depth+eps, center=false );

    // three screws holes on the base/reference part
    //
    for( phi=[0,120,240] ) {
      rotate( [0,0,phi+90+5] ) 
        translate( [rs, 0, -total_height-eps] )
          cylinder( d=m2, h=screw_depth+2*eps, center=false );
    } 

    // three slots for M2 nuts, in case the object is used
    // as a mechanical dummy for mounting the actual sensor
    // DIN says: M2 nut height = 1.6mm, M2 e (diagonal) = 4.38mm
    if (nut_slots) {
      m2nut = 4.5;
      m2hhh = 2.0;
      for( phi=[0,120,240] ) {
        rotate( [0,0,phi+90+5] ) {
          translate( [rs, 0, -total_height+1] )
            cylinder( d=m2nut, h=m2hhh, $fn=6, center=false );
          translate( [rs+2, 0, -total_height+1] )
            cylinder( d=m2nut, h=m2hhh, $fn=6, center=false );
        }
      } 
    }  // if nut_slots
    
    
    // three screws used by ATi to hold the sensor together
    //
    for( phi=[60,180,300] ) {
      rotate( [0,0,phi] ) {
        translate( [rs, 0, -total_height-eps] ) 
          cylinder(d=m2, h=2+eps, $fn=6, center=false );
        translate( [rs, 0, -total_height-eps] ) 
          cylinder( d=m2hex, h=0.5+2*eps, , center=false );
      }
    } 
    

  }
}



/**
 * ATi nano17e tool-side mounting plate with three M2 screws,
 * oriented along ATi reference coordinate axes.
 */
module ati_nano17e_tool_mounting_plate( diameter=17.5, h=2, inbus=false, inbus_head_height=2 ) {

  m2          = 2.0;    // diameter of M2 screw thread
  m2hex       = 3.0;    // diameter of M2 hex screw head
  rs          = 12.5/2; // radius of screws

  difference() {
    cylinder( d=diameter, h=h, center=false );

    // three M2 screw holes 
    //
    for( phi=[0,120,240] ) {
      rotate( [0,0,phi+60] ) 
        translate( [rs, 0, -eps] )
          cylinder( d=m2, h=h+2*eps, center=false );
    } 

    // cavities for three M2 inbus screw heads (if requested)
    //
    for( phi=[0,120,240] ) {
      rotate( [0,0,phi+60] ) 
        translate( [rs, 0, h-inbus_head_height] )
          cylinder( d=m2hex, h=inbus_head_height+eps, center=false );
    } 

  }
}


/**
 * ATi nano17e base-side mounting plate with three M2 screws,
 * oriented along ATi reference coordinate axes.
 */
module ati_nano17e_base_mounting_plate( h=2, inbus=false, inbus_head_height=1 ) {

  m2          = 2.0;    // diameter of M2 screw thread
  m2hex       = 4.5;    // diameter of M2 hex screw head (real is: 3.8mm)
  rs          = 12.5/2; // radius of screws

  difference() {
    cylinder( d=17.5, h=h, center=false );

    // three M2 screw holes 
    //
    for( phi=[0,120,240] ) {
      rotate( [0,0,phi+90+5] ) 
        translate( [rs, 0, -eps] )
          cylinder( d=m2, h=h+2*eps, center=false );
    } 

    // cavities for three M2 inbus screw heads (if requested)
    //
    for( phi=[0,120,240] ) {
      rotate( [0,0,phi+90+5] ) 
        translate( [rs, 0, -eps] )
          cylinder( d=m2hex, h=inbus_head_height+eps, center=false );
    } 

  }
}




module gray08() {
  color( [0.8, 0.8, 0.8] ) children();
}


module gray07() {
  color( [0.7, 0.7, 0.7] ) children();
}


module gray02() {
  color( [0.2, 0.2, 0.2] ) children();
}




/**
 * cylinder that fits a nut of given metric size,
 * e.g. m=4 means M4.
 * https://www.boltdepot.com/fastener-information/nuts-washers/Metric-Nut-Dimensions.aspx
 * diameter is across the flats, also the size of wrench to use.
 * M2: diameter 4.0, height 1.6
 * M2.5: 5.0 2.0
 * M3:   5.5 2.4
 * M4:   7.0 3.2
 * M5:   8.0 4.0
 * M6:   10.0 5.0
 * ...
 */
module metric_nut_mount( outer_diameter=20, thickness=3.5, m=7.0, fn=30, eps=0.01 ) 
{
  color( [1,1,0] )
  difference() {
    cylinder( d=outer_diameter, h=thickness+eps, center=true, $fn=fn );
    cylinder( d=m, h=thickness+2*eps, center=true, $fn=6 );
  }
}

