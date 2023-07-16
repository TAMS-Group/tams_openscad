/** ur5_flange.scad
 * 
 * Simplified models of the UR5/UR5e tool mounting flange and the
 * robot base mounting flange.
 *
 * 2023.06.29 - created
 *
 * (c) 2023, fnh, hendrich@informatik.uni-hamburg.de
 */
 
 
eps = 0.1;
ffn = 150;
 
 
translate( [0,0,0] )    ur5_tool_flange(); // UR5 wrist link6
translate( [0,0,-100] ) ur5_mounting_flange(); // UR5 base-link


/** simplified model of the UR5 tool flange, ISO 9409-1-50-4-M
 *  d_outer = 75, d_flange = 63, d_screws = 50, d_inner = 31.5,
 *  four screws M6 depth 6, 
 *  one alignment pin d=6, same direction as cable connector,
 *  whichis Lumberg RKMW 8-354, dz 31.55 below flange.
 *  outer flange height 6.5, inner depth 6.20, h_flange = 45.75.
 *  Model is centered in x and y, with tool flange at z=0.
 */
module ur5_tool_flange()
{
  d_outer   = 75.0; d_flange = 63.0; d_screws = 50.0; d_inner = 31.50;
  h_flange = 45.75; h_top = 6.50; h_inner = 6.20; h_bevel = 1.0;
  l_screw_bore = 6.50;

  color( "silver" ) 
  union() {
    // main robot arm and bevel    
    translate( [0,0,-h_flange] )
      cylinder( d=d_outer, h=(h_flange-h_top-h_bevel), center=false, $fn=300 );
    translate( [0,0,-h_top-h_bevel] )
      cylinder( d1=d_outer, d2=d_outer-2*h_bevel, h=h_bevel, center=false, $fn=300 );
    // sideways tool electric connector
    translate( [d_outer/2,0,-19.5] ) rotate( [0,90,0] )
      cylinder( d=10, h=10, center=false, $fn=30 );
  }
    
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


/** simplified model of the UR5 mounting flange (base link).
 *  d_outer = 149, d_screws = 132, 
 *  four screws M8 (d=8.5) depth 12 (4).
 *  two alignment pins d=8, distance (60,10,0) 45 degrees from center.
 *  Model is centered in x and y, with bottom at z=0.
 */
module ur5_mounting_flange( color="silver" )
{
  d_outer = 149.0; h_plate = 12.0; d_screws = 132.0; d_align = 120.0;
  M8BORE = 8.5;
  difference() {
    union() {
      // main mounting plate
      color( color )
      cylinder( d=d_outer, h=h_plate, center=false, $fn=300 );

      color( color )
      translate( [0,0,h_plate] ) 
        cylinder( d=110, h=10, center=false, $fn=300 );
 
      color( color )
      rotate( [0,0,45] ) 
      intersection() {
        h_cube = 5;
        translate( [0,0,h_plate-eps] )
          cylinder( d=d_outer, h=h_cube, center=false, $fn=300 );
        translate( [0,0,h_plate+h_cube/2] )
          cube( size=[d_outer,70,h_cube], center=true );
      }

      color( color )
      intersection() {
        h_cube = 5;
        translate( [0,0,h_plate-eps] )
          cylinder( d=d_outer, h=h_cube, center=false, $fn=300 );
        rotate( [0,0,135] ) 
        translate( [0,0,h_plate+h_cube/2] )
          cube( size=[d_outer,70,h_cube], center=true );
      }
    }

    // four bores M8
    for( alpha=[0,90,180,270] ) {
      rotate( [0,0,alpha] )
        translate( [d_screws/2, 0, -eps] )
          cylinder( d=M8BORE, h=h_plate+2*eps, center=false, $fn=50 );
    }

    // weird asymmetric alignment pins
    rotate( [0,0,45] ) {
      translate( [d_align/2, 10, -eps] ) 
        cylinder( d=8.0, h=h_plate+2*eps, center=false, $fn=50 );
      translate( [-d_align/2, 10, -eps] ) 
        cylinder( d=8.0, h=h_plate+2*eps, center=false, $fn=50 ); 
    }

    // central alignment bore :-)
    translate( [0,0,-eps] )
      cylinder( d=2, h=30, center=false, $fn=10 );
  }
}


