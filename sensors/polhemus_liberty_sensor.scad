/* polhemus_rx2_sensor.scad
 * 
 * Simple 3D model of the Polhemus Liberty RX2 magnetic sensor,
 * for rviz visualization and for building sensor housings.
 * Note that the RX2 is the "normal" size sensor, much bigger
 * than the newer "micro" sensors.
 *
 * 22.02.2017 - created
 *
 * (C) 2017 fnh, hendrich@informatik.uni-hamburg.de
 */


// Note: dimensions are in millimeters
$fn = 50;
eps = 0.1;


translate( [0,0,0] ) polhemus_rx2_sensor( external_screws_height = 50 );
translate( [50,0,0] ) polhemus_rx2_sensor( external_screws_height = 0 );


module polhemus_rx2_sensor( external_screws_height = 0,  )
{
  // the base inner "cube" has dx=22.86, dy=15.3, and dz=6.35
  dx = 22.86;
  dy = 15.3;
  dz =  6.35;
  // the base outer (screw) corners are at yy=28.3
  // the base screws are at ys=20.65/2
  yy = 28.3;
  ys = 20.65;
  
  difference() {
    union() {
      // hexagonal base plate
      //
      color( [0.8,0.8,0.8] )
      hull() {
        translate( [-dx/2,-dy/2,dz/2] ) cylinder( d=1, h=dz, center=true );
        translate( [-dx/2,+dy/2,dz/2] ) cylinder( d=1, h=dz, center=true );
        translate( [+dx/2,-dy/2,dz/2] ) cylinder( d=1, h=dz, center=true );
        translate( [+dx/2,+dy/2,dz/2] ) cylinder( d=1, h=dz, center=true );
        translate(     [0,-ys/2,dz/2] ) cylinder( d=(yy-ys), h=dz, center=true );
        translate(     [0,+ys/2,dz/2] ) cylinder( d=(yy-ys), h=dz, center=true );
      }
      
      // upper sensor housing, sensor/coil cube seems to be 15x15x15
      //
      cc = 15.0; 
      color( [0.5,0.5,0.5] )
      hull() {
        translate( [-dx/2+cc/2,0,cc/2+eps] ) cube( size=[cc,cc,cc], center=true );
        translate( [+dx/2,0,dz] ) rotate( [90,0,0] ) cylinder( d=1, h=cc, center=true );       
      }
      
      // cable stub
      //
      color( [0.8,0.8,0.8] )
      translate( [dx/2,0,dz/2] ) rotate( [0,90,0] ) cylinder( d=3,h=11, center=false );
      
      // marker for sensor origin / zero-position
      // 
      color( [1,0,0] ) {
        translate( [-3.175,0,15.24-7.2898] ) rotate( [0,90,90] ) cylinder( d=1, h=cc+eps, center=true );
        translate( [-3.175, 0,15.24/2] ) cylinder( d=1, h=15.24+eps, center=true );
      }
      
      // optional long screws (when the model is used to cut-out 
      // then sensor from another 3D model)
      //
      if (external_screws_height > 0) {
        translate( [0,-ys/2,dz/2] ) cylinder( d=3, h=external_screws_height, center=true );
        translate( [0,+ys/2,dz/2] ) cylinder( d=3, h=external_screws_height, center=true );
      }
      
    } // end union
    
    // screw holes (unless the user has requested external_screw_height > 0)
    //
    if (external_screws_height <= 0) {
      translate( [0,-ys/2,dz/2] ) cylinder( d=3, h=dz+eps, center=true );
      translate( [0,+ys/2,dz/2] ) cylinder( d=3, h=dz+eps, center=true );
    }
  } // end difference
}


