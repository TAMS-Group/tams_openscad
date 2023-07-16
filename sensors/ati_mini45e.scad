/** ati_mini45e.scad - ATi mini45e F/T sensor
 *
 * 3D-model of the ATi mini45 (type e) six-axis F/T sensor
 * with matching mounting plates.
 *
 * Note that the sensor is oriented below the z=0 plane,
 * so that the sensing axes are aligned with the Openscad axes.
 *
 * Note: the object (especially with nut_slots=true) may be
 * too complex for the default OpenSCAD settings. If you receive
 * this warning: "Normalized tree is growing past 4000 elements"
 * the rendered object(s) may be incomplete. Go to the settings
 * menu and increase the value in the OpenGL "rendern abbrechen"
 * text field.
 *  
 * Dimensions are in millimeters; use an outer scale( 0.001 )
 * if you need meters (e.g., conversion to ROS URDF).
 *
 * 21.12.2017 - created, based on ATi datasheet 9230-05-1311.auto.pdf
 *
 * (C) 2017 fnh, hendrich@informatik.uni-hamburg.de
 */


eps=0.01; 
$fn = 100; 

m2          = 2.2;    // diameter of M2 screw thread
m2hex       = 4.0;    // diameter of M2 hex screw head (norm says: 3.8)
m3          = 3.3;    // diameter of M3 screw thread
m3hex       = 5.5;    // diameter of M3 hex screw head (norm sys: 

rtool       = 28.2/2; // distance of tool side screws from sensor center
rbase       = 39.24/2; // base mounting screws "diameter" 39.24




translate( [0,0,0] )  ati_mini45e( nut_slots=false );
translate( [0,0,5] ) ati_mini45e_tool_mounting_plate( d=45, h=4, inbus=true, inbus_head_height=2 );
translate( [0,0,-25] ) ati_mini45e_base_mounting_plate( d=45, h=4, inbus=true, inbus_head_height=2 );

// translate( [60,0,0] ) ati_mini45e( nut_slots=false );
// translate( [120,0,0] ) ati_mini45e( nut_slots=true );
// translate( [180,0,0] ) ati_mini45e( nut_slots=false );

// translate( [0,0,5] ) ati_mini45e_tool_mounting_plate( d=45, h=4, inbus=true, inbus_head_height=2 );
// translate( [0,0,-25] ) ati_mini45e_base_mounting_plate( d=45, h=4, inbus=true, inbus_head_height=2 );



module ati_mini45e( nut_slots=false ) {
  total_height = 15.7;
  tool_part_height = 3.0; // guessed, not specified exactly
  bottom_part_height = total_height - tool_part_height - 0.5;


  cable_diameter = 5.3;
  cable_height   = 3.5; // cable_diameter + 2;
  cable_housing  = 26.5;
  cable_shield   = 17.5;

  difference() { 
    union() { 
      // main, "bottom" part of the sensor
      // 
      gray08() translate( [0,0,-total_height] ) cylinder( d=45.0, h=bottom_part_height, center=false );

      // shorter, "upper"/"tool" part of the sensor
      // 
      gray08() translate( [0,0,-tool_part_height] ) cylinder( d=45.0, h=tool_part_height, center=false );

      gray02() translate( [0,0,-tool_part_height-0.5-eps] ) 
        cylinder( d=45.0-3, h=0.5+4*eps, center=false );


      // mini45e cable housing (simplified) 
      x = 15.5;
      dz = 12.1;
      gray07() 
        rotate( [0,0,20] ) 
          translate( [0,cable_housing/2, -total_height + dz/2] ) 
            cube( size=[x, cable_housing, dz-2*eps], center= true );

      // nano17e cable (simplified)
      //
      gray02()
        translate( [0,0,-total_height+cable_height] )
          rotate( [-90,0,20] ) 
            cylinder( d=cable_diameter, h=cable_housing+cable_shield, center=false );
            
            
       // axis labels on the side            
       translate( [ 45.0/2-eps, 0,-2] ) rotate( [0,-90,180] )  letter( "+X" );
       translate( [-45.0/2+eps, 0,-2] ) rotate( [0,-90,0] )    letter( "-X" );
       translate( [ 0, 45.0/2-eps,-2] ) rotate( [90,-90,180] ) letter( "+Y" );
       translate( [ 0,-45.0/2+eps,-2] ) rotate( [90,-90,0] )   letter( "-Y" );
    } // union


    // reference pins (d=3 depth=3.2) on the upper/toor part
    //
    rsf_depth = 3.2;
    rotate( [0,0,0] ) translate( [rtool, 0, -rsf_depth] ) 
      cylinder( d=3.0, h=rsf_depth+eps, center=false );
    rotate( [0,0,120] ) translate( [rtool, 0, -rsf_depth] ) 
      cylinder( d=3.0, h=rsf_depth+eps, center=false );

    // six M3 screw holes (depth 0.5) on the upper/tool part of the sensor
    //
    screw_depth = 3.0;
    for( phi=[-40,+40,-40+120,+40+120,-40+240,+40+240] ) {
      rotate( [0,0,phi] ) 
        translate( [rtool, 0, -screw_depth-eps] )
          cylinder( d=m3, h=screw_depth+2*eps, center=false );
    } 

    
    if (nut_slots) {
      m3nut = 6.5;
      m3hhh = 2.6;
      for( phi=[-40,+40,-40+120,+40+120,-40+240,+40+240] ) {
        rotate( [0,0,phi] ) 
          translate( [rtool, 0, -m3hhh-1] )
            rotate( [0,0,30] ) 
              cylinder( d=m3nut, h=m3hhh, $fn=6, center=false );
        
        rotate( [0,0,phi] ) 
          translate( [rtool+(45/2-rtool)/2, 0, -m3hhh/2-1] )
            rotate( [0,0,90] ) 
              cube( size=[m3nut,(10),m3hhh], center=true );
      } 
    }  // if nut_slots
    

    // six inner screws used by ATi to hold the sensor together
    //
    rrr = 13.0;
    for( phi=[-20,+20,-20+120,+20+120,-20+240,+20+240] ) {
      rotate( [0,0,phi] ) {
        translate( [rrr, 0, -2] ) 
          cylinder(d=m2, h=2+eps, $fn=6, center=false );
        translate( [rrr, 0, -0.5] ) 
          cylinder( d=5.6, h=0.5+eps, $fn=20, center=false );
      }
    } 
    
    // reference pins (d=3 depth=5) on base/reference part
    //
    index_depth = 5.0;
    rotate( [0,0,0] ) translate( [rbase, 0, -total_height-eps] ) 
      cylinder( d=3.0, h=index_depth+eps, center=false );

    // six M3 mounting screws holes on the base/reference part
    //
    for( phi=[-10, 10, -10+120, +10+120, -10+240, +10+240] ) {
      rotate( [0,0,phi+180] ) 
        translate( [rbase, 0, -total_height-eps] )
          cylinder( d=m3, h=screw_depth+2*eps, center=false );
    } 

    // six slots for M3 nuts, in case the object is used
    // as a mechanical dummy for mounting the actual sensor
    // DIN says: M3 nut height = 2.4mm, M2 e (diagonal) = 6.08mm
    if (nut_slots) {
      m3nut = 6.5;
      m3hhh = 2.6;
      for( phi=[-10, 10, -10+120, +10+120, -10+240, +10+240] ) {
        rotate( [0,0,phi+180] ) {
          translate( [rbase, 0, -total_height+2] )
            cylinder( d=m3nut, h=m3hhh, $fn=6, center=false );
          translate( [rbase+2, 0, -total_height+2] )
            cylinder( d=m3nut, h=m3hhh, $fn=6, center=false );
        }
      } 
    }  // if nut_slots
   
    // six screws used by ATi to hold the sensor together
    //
    rbb = 37.24/2; // only estimated, not specified in datasheet
    for( phi=[-20, 20, -20+120, 20+120, -20+240, 20+240] ) {
      rotate( [0,0,phi] ) {
        translate( [rbb, 0, -total_height-eps] ) 
          cylinder(d=m3-2, h=2+eps, $fn=6, center=false );
        translate( [rbb, 0, -total_height-eps] ) 
          cylinder( d=m3hex+1, h=0.5+2*eps, $fn=20, center=false );
      }
    } 

    // inner bore, diameter 9.538
    translate( [0,0,-total_height/2] ) 
      cylinder( d=9.538, h=total_height+2*eps, $fn=30, center=true );    
  }
}



/**
 * ATi mini45e tool-side mounting plate with three M3 screws,
 * oriented along ATi reference coordinate axes.
 */
module ati_mini45e_tool_mounting_plate( d=50, h=2, inbus=true, inbus_head_height=2, refpin=true, center_bore=true ) {

  difference() {
    union() {
      cylinder( d=d, h=h, center=false );
    
      // optionally, generate reference pin (d=3 depth=3.2) on the mounting plate
      //
      if (refpin) {
        rsf_depth = 2.0; // max 3.2;
        rotate( [0,0,0] ) translate( [rtool, 0, -rsf_depth] ) 
         cylinder( d=3.0, h=rsf_depth+eps, center=false );
      }
    }
  
    // six M3 screw holes through the mounting plate
    //
    for( phi=[-40,+40,-40+120,+40+120,-40+240,+40+240] ) {
      rotate( [0,0,phi] ) 
        translate( [rtool, 0, -eps] )
          cylinder( d=m3, h=h+2*eps, center=false );
    } 
    
    // cavities for six M3 inbus screw heads (if requested)
    //
    for( phi=[-40,+40,-40+120,+40+120,-40+240,+40+240] ) {
      rotate( [0,0,phi] ) 
        translate( [rtool, 0, h-inbus_head_height] )
          cylinder( d=m3hex, h=inbus_head_height+eps, center=false );
    } 

    if (center_bore) {
      translate( [0,0,h/2] ) 
        cylinder( d=9.538, h=h+2*eps, $fn=50, center=true );    
    }
  }
}


/**
 * ATi mini45e base-side mounting plate with six M3 screws,
 * oriented along ATi reference coordinate axes.
 */
module ati_mini45e_base_mounting_plate( d=50, h=2, inbus=false, inbus_head_height=1, center_bore=true ) {

  difference() {
    cylinder( d=d, h=h, center=false );
    
    // six M3 mounting screws holes on the base/reference part
    //
    for( phi=[-10, 10, -10+120, +10+120, -10+240, +10+240] ) {
      rotate( [0,0,phi+180] ) 
        translate( [rbase, 0, -eps] )
          cylinder( d=m3, h=h+2*eps, center=false );
    } 

    // cavities for three M2 inbus screw heads (if requested)
    //
    for( phi=[-10, 10, -10+120, +10+120, -10+240, +10+240] ) {
      rotate( [0,0,phi+180] ) 
        translate( [rbase, 0, -eps] )
          cylinder( d=m3hex, h=inbus_head_height+eps, center=false );
    } 

    // inner bore, diameter 9.538, if requested
    if (center_bore) {
      translate( [0,0,h/2] ) 
        cylinder( d=9.538, h=h+2*eps, $fn=50, center=true );    
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



module letter( l, letter_size=1.0, extrude_height=0.2 ) {
  font = "Liberation Sans";
	// Use linear_extrude() to make the letters 3D objects as they
	// are only 2D shapes when only using text()
  color( [0,0,0] ) 
  	linear_extrude(height = extrude_height) {
	  	text(l, size = letter_size, font = font, halign = "center", valign = "center", $fn = 16);
	}
}


