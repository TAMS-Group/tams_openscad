/** fischertechnik_adapter.scad - ft parts and "TAMS outer flange" 
 *
 * This model provides 3D-printable models for the fischertechnik toys
 * and construction kits, and in particular a base-plate using the
 * TAMS flange (outer, d=99mm) geometry. This allows you to mount
 * fischertechnik prototypes on top of our UR5/Kuka/Diana7 robots.
 *
 * 
 * 2023.07.14 - created (loosely based on thingiverse 3574034 and 3571988)
 *
 * (c) 2023 fnh, hendrich@informatik.uni-hamburg.de
 */

use <../robots/tams_flange_outer_adapter.scad>
// use <../tmp/fischertechnik_blocks.scad> // slot macros are still inline here

eps = 0.1;
_fn = 50;



tams_flange_outer_adapter( h_upper=1 );
translate( [0,0,12-eps] )
  ft_base_plate_circular( 
    dd=99, tt=8, 
    center_bores = [[0,0,4]]
  );







/**
 * normal (gray) fischertechnik block, oriented towards +x,
 * centered in y and z, origin at x=0.
 */
module block_x( dd=15, ll=30, tolerance=0.03, top_slot=true, base_slot=true )
{
  difference() {
    translate( [ll/2,0,0] )
      cube( [ll, dd, dd], center=true );

    // four slots along the sides of the block
    for( alpha=[0,90,180,270] ) 
      rotate( [alpha,0,0] )
        translate( [ll/2, 0, dd/2 + tolerance/2] )
          ft_cylindrical_slot( length=ll+eps, tolerance=tolerance );

    // base and top slots
    if (base_slot) 
    translate( [0, 0, 0] )
      rotate( [0,-90,0] )
        ft_cylindrical_slot( length=dd+eps, doors=3, tolerance=tolerance );

    if (top_slot)
    translate( [ll, 0, 0] )
      rotate( [0,90,0] )
        ft_cylindrical_slot( length=dd+eps, doors=3, tolerance=tolerance );
        
  }
}


/**
 * normal (gray) fischertechnik block, oriented towards +x,
 * centered in y and z, origin at x=0.
 */
module block_x_angular( dd=15, ll=30, tolerance=0.03 )
{
  difference() {
    translate( [ll/2,0,0] )
      cube( [ll, dd, dd], center=true );

    // four slots along the sides of the block
    for( alpha=[0,90,180,270] ) 
      rotate( [alpha,0,0] )
        translate( [ll/2, 0, dd/2 + tolerance/2] )
          ft_angular_slot( length=ll+eps, tolerance=tolerance );

    // top and bottom slots
    translate( [0, 0, 0] )
      rotate( [0,-90,0] )
        ft_angular_slot( length=dd+eps, doors=3, tolerance=tolerance );

    translate( [ll, 0, 0] )
      rotate( [0,90,0] )
        ft_angular_slot( length=dd+eps, doors=3, tolerance=tolerance );
        
  }
}





/**
 * a plate of given size, centered in x and y, origin at z=0,
 * with given slots oriented along x and y axis.
 * For each slot, give center_x, center_y, length, type 0/1,
 * where type=0 is cylindrical (default) and type=1 means angular.
 */
module ft_base_plate( 
  sx=6*15, sy=5*15, sz=10,
  x_slots = [],
  y_slots = [],
  tolerance = 0.01,
)
{
  difference() {
    translate( [0,0,sz/2] )
      cube( [sx, sy, sz], center=true );
    for( slot=x_slots ) {
      echo( "X SLOT is: ", slot );
      translate( [slot[0], slot[1], sz] )
        ft_cylindrical_slot( length=slot[2], doors=3, tolerance=tolerance );
    }
    for( slot=y_slots ) {
      echo( "Y SLOT is: ", slot );
    }
  }
}


/**
 * default robot mount plate with given diameter dd, thickness tt,
 * two centered slots along +x, and the rest of the plate
 * filled with slots along +y
 */
module ft_base_plate_circular( 
  dd = 99, tt= 8,
  center_bores = [[0,0,4.0]], // ft axis diameter, increase for cable passthrough
  tolerance = 0.02,
)
{
  difference() {
    translate( [0,0,0] )
      cylinder( d=dd, h=tt, center=false, $fn=300 );

    // two centered along-x slots along the full width
    for( dy=[-7.5, +7.5] ) {
      translate( [0, -dy, tt] )
        ft_cylindrical_slot( length=dd+1, doors=3, tolerance=tolerance );
    }
    translate( [27.5,0,tt] )
      ft_cylindrical_slot( length=45, doors=3, tolerance=tolerance );
    translate( [-27.5,0,tt] )
      ft_cylindrical_slot( length=45, doors=3, tolerance=tolerance );


    // user-defined bores at given positions and diameters
    for( bore = center_bores ) {
      translate( [bore[0], bore[1], -eps] )
        cylinder( d=bore[2], h=tt+2*eps, center=false, $fn=_fn ); 
    }

    // rest of the plate filled with along-y slots
    //
    for( dx=[0:15:45] ) {
      echo( "DX...", dx );
      translate( [dx, dd/2+15, tt] )
        rotate( [0,0,90] ) 
          ft_cylindrical_slot( length=dd+1, doors=0, tolerance=tolerance );
      translate( [-dx, dd/2+15, tt] )
        rotate( [0,0,90] ) 
          ft_cylindrical_slot( length=dd+1, doors=0, tolerance=tolerance );
      translate( [dx, -dd/2-15, tt] )
        rotate( [0,0,90] ) 
          ft_cylindrical_slot( length=dd+1, doors=0, tolerance=tolerance );
      translate( [-dx, -dd/2-15, tt] )
        rotate( [0,0,90] ) 
          ft_cylindrical_slot( length=dd+1, doors=0, tolerance=tolerance );
    }
  }
}



/**
 * model of the original (cylindrical) fischertechnik mounting slot,
 * fixed diameter 4mm, given length, centered, oriented towards +x.
 * I doors=1/2/3 is given, add 4mm cubical at the base end, top end,
 * or both ends.
 */
module ft_cylindrical_slot( length=15, doors=0, tolerance=0.03 )
{
  s = 4 + tolerance;
  union() {
    translate( [0,0,-2] )
      rotate( [0,90,0] ) 
        cylinder( d=4.0+tolerance, h=length+2*eps, center=true, $fn=_fn );
    translate( [0, 0, 0]) 
      cube( [length+eps, 3+tolerance/2, 3+tolerance/2], center=true);
    if (doors&&1 > 0) {
      translate( [length/2-2,0,0] ) cube( [s,s,s], center=true );
    }
    if (doors&&2 > 0) {
      translate( [-length/2+2,0,0] ) cube( [s,s,s], center=true );
    }
  }
  
}


/**
 * model of the newer (angled) fischertechnik mounting slot,
 * fixed diameter 4mm, given length, centered in y,
 * short side at z=0, long size at z=-2, oriented towards +x.
 */
module ft_angular_slot( length=15, doors=0, tolerance=0.03 )
{
  p1 = [0,0];
  p2 = [ -2.05 - tolerance / 2,   0 ];
  p3 = [ -2.05 - tolerance / 2,   0.2 ];
  p4 = [ -1.5  - tolerance / 2,   2.3 + tolerance / 2];
  p5 = [ -1.5  - tolerance / 2,   2.9 + tolerance / 2];
  p6 = [  1.5  + tolerance / 2,   2.9 + tolerance / 2];
  p7 = [  1.5  + tolerance / 2,   2.3 + tolerance / 2];
  p8 = [  2.05 + tolerance / 2,   0.2 ];
  p9 = [  2.05 + tolerance / 2,   0 ];

  translate([length/2, 0, -2.9]) {
    rotate( [90,0,-90] ) 
      linear_extrude(height = length+2*eps, scale=1)
        polygon( [ p1, p2, p3, p4, p5, p6, p7, p8, p9 ] );
  }

  s = 4 + tolerance;
  if (doors&&1 > 0) {
    translate( [+length/2-2,0,0] ) cube( [s,s,s], center=true );
  }
  if (doors&&2 > 0) {
    translate( [-length/2+2,0,0] ) cube( [s,s,s], center=true );
  }
} // ft_angular_slot


module ft_insertion_slot_z( tolerance=0.03 )
{
  cube( [4,4,2], center=true );
}


