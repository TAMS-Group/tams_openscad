/** ur10_flange.scad
 * 
 * Simplified models of the UR10/UR10e tool mounting flange and the
 * robot base mounting flange.
 *
 * 2023.06.29 - created
 *
 * (c) 2023, fnh, hendrich@informatik.uni-hamburg.de
 */
 
 
eps = 0.1;
ffn = 150;

translate( [0,0,0] )    ur10_tool_flange();     // UR10 wrist link6
translate( [0,0,-100] ) ur10_mounting_flange(); // UR10 base


/** simplified model of the UR10 tool flange, ISO 9409-1-50-4-M
 *  d_outer = 90, d_flange = 63, d_screws = 50, d_inner = 31.5,
 *  four screws M6 depth 6, 
 *  one alignment pin d=6, same direction as cable connector,
 *  whichis Lumberg RKMW 8-354, dz 14.5mm below flange.
 *  outer flange height 6.5, inner depth 6.20, h_flange = 45.75.
 *  Model is centered in x and y, with tool flange at z=0.
 */
module ur10_tool_flange()
{
  d_outer   = 90.0; d_flange = 63.0; d_screws = 50.0; d_inner = 31.50;
  h_flange = 45.75; h_top = 6.50; h_inner = 6.20; h_bevel = 1.0;
  l_screw_bore = 6.50;

  color( "silver" ) 
  difference() {
    union() {
      // main robot arm and bevel    
      translate( [0,0,-h_flange] )
        cylinder( d=d_outer, h=(h_flange-h_top-h_bevel), center=false, $fn=300 );
      translate( [0,0,-h_top-h_bevel] )
        cylinder( d1=d_outer, d2=d_outer-2*h_bevel, h=h_bevel, center=false, $fn=300 );
    }
    // connector cutout
    translate( [40.2,0,-14.5] )
      cube( [12,38,18], center=true );
  }

  // sideways tool electric connector
  color( "gray" )
  translate( [40.2,0,-14.5] ) rotate( [0,-90,0] )
    cylinder( d=11, h=12, center=false, $fn=30 );
    
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
    
    // four M6 bores, depth 6
    for( alpha=[0,90,180,270] ) {
      rotate( [0,0,alpha+45] ) translate( [d_screws/2,0,-l_screw_bore+eps] ) 
        cylinder( d=6.2, l_screw_bore, center=false, $fn=50 );
    } 

    // alignment pin bore
    rotate( [0,0,0] ) translate( [d_screws/2,0,-6.20+eps] ) 
      cylinder( d=6.00, h=6.20, center=false, $fn=100 );
  }
}


/** simplified model of the UR10 mounting flange (base link).
 *  d_outer = 190, d_inner= 150, d_screws = 170, 
 *  four screws M8 (d=8.5) depth 12 (4).
 *  two alignment pins d=8, distance (60,10,0) 45 degrees from center.
 *  Model is centered in x and y, with bottom at z=0.
 */
module ur10_mounting_flange()
{
  d_outer = 190.0; 
  d_inner = 156.0; h_plate = 12.0; 
  d_screws = 170.0; d_align = 120.0; M8BORE = 8.5;

  difference() {
    union() {
      // thin reference plate
      color( "lightblue" )
      translate( [0,0,1*eps] ) 
        cylinder( d=d_outer, h=1, center=false, $fn=300 );

      // main inner plate
      color( "silver" )
      cylinder( d=d_inner, h=h_plate, center=false, $fn=300 );

      color( "silver" )
      for( alpha=[0,90,180,270] ) {
        rotate( [0,0,alpha+45] )
          translate( [d_screws/2-15, 0, 0] )
            cylinder( d=50, h=h_plate, center=false, $fn=50 );
      }
    } // union

    // cable/connector plateau
    translate( [0, d_inner/2, h_plate/2+2] )
      cube( [55, 10, h_plate], center=true );

    // four bores M8
    for( alpha=[0,90,180,270] ) {
      rotate( [0,0,alpha+45] )
        translate( [d_screws/2, 0, -eps] )
          cylinder( d=M8BORE, h=h_plate+2*eps, center=false, $fn=50 );
    }

    // weird asymmetric alignment pins
    rotate( [0,0,0] ) {
      translate( [d_align/2, 10, -eps] ) 
        cylinder( d=8.0, h=h_plate+2*eps, center=false, $fn=50 );
      translate( [-d_align/2, 10, -eps] ) 
        cylinder( d=8.0, h=h_plate+2*eps, center=false, $fn=50 ); 
    }

    // central alignment bore :-)
    translate( [0,0,-eps] )
      cylinder( d=2, h=h_plate+2*eps, center=false, $fn=10 );
  }
}
