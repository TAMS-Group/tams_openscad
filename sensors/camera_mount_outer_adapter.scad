/** camera_mount_outer_adapter.scad - adapter plate to mount one or
 *  multiple cameras to a robot.
 *
 * This model provides a 3D-printable adapter plate with bores
 * for 1/4 inch and 3/8 inch screws as found on most cameras
 * and camera ball-heads (d=6.35 mm d=9.53 mm).
 * The outer 3/8 inch mounts are arranged to fit multiple 
 * Manfrotto ball-heads (d_outer 45 mm).
 * (outer, d=99mm) geometry. 
 *  
 * The plate is rather thick (12 mm core, 5 mm plate, 10 mm "cavities"),
 * as typical camera screws have a thick head that cannot easily be
 * hidden in the core adapter.
 * 
 * 2023.07.14 - created
 *
 * (c) 2023 fnh, hendrich@informatik.uni-hamburg.de
 */

use <../robots/tams_flange_outer_adapter.scad>
use <../sensors/digit_sensor.scad>
use <../libs/simple_screws.scad>

eps = 0.1;
_fn = 50;
_inch = 25.4;
ee = 0;


translate( [0,0,0] ) camera_mount_outer_adapter();


//intersection() {
//translate( [0,0,0] ) camera_mount_outer_adapter();
//translate( [0,0,20] ) 
//cube( [200,50,40], center=true );
//}

translate( [0,0,12] ) camera_screw( c_head="black" );
translate( [100,0,0] ) camera_screw( c_head="brown" );
translate( [0,100,0] ) camera_screw( d_screw=9.5, h_head=4, d_head=20, c_head="silver" );



module camera_mount_outer_adapter() {
  h_core = 12.0; h_upper = 5+10;
  difference() {
    tams_flange_outer_adapter( h_core=h_core, h_upper=h_upper, d_inner = 0 );

    // inner cutout to handle screws
    translate( [0, 0, h_core-eps] )
      cylinder( d=76.0, h=10.0, center=false, $fn=100 );

    // central 1/4 inch bore with cavity for a large d=40mm h=10mm head
    translate( [0, 0, h_core-eps] )
      cylinder( d=1/4*_inch, h=h_upper+2*eps, center=false, $fn=30 );

    translate( [0, 0, h_core-eps] )
      screw_collection();
  }
}

//translate( [0,0,12+eps] )
//  camera_screw( l_screw=20 );

module screw_collection() {
  for( dx=[-25, -12.5, 0, 12.5, 25] ) 
    translate( [dx,0,0] )
      camera_screw( l_screw=20, d_head=18 );

  for( dy=[-25, 25] ) 
    translate( [0,dy,0] )
      camera_screw( l_screw=15, d_head=16 );

  for( alpha=[0,90,180,270] )
    rotate( [0,0,alpha+45] )
      translate( [25,0,0] )
       camera_screw( d_screw=3/8*_inch, l_screw=15, d_head=20, h_head=5 );
}

module camera_screw(
  d_screw = 1/4*_inch,
  l_screw = 13.0,
  d_head  = 28.0,
  h_head  =  8.0,
  c_head  = "silver",
)
{
  color( "silver" )
  translate( [0,0,h_head] )
    cylinder( d=d_screw, h=l_screw, center=false, $fn=50 );
  color( c_head )
  translate( [0,0,0] )
    cylinder( d=d_head, h=h_head, center=false, $fn=100 );
}



