/** feetech-servos.scad
 * 
 * geometry models of several FeeTech model servos, including:
 * FS5113R          - analog continuous rotation servo
 * SCS15            - 15kg cm 7.4V digital bus servo
 * SCS20-360T/TTL   - 20kg cm 7.4V digital bus servo
 * SCS09            - digital bus micro servo 5V (6V? 7.4V ??)
 *
 * All dimensions are in millimeters as measured by hand, 
 * as no datasheet was available. Precision should be around 0.1mm, 
 * but some rounded edges and fine details are not modeled.
 *
 * Body origin is at the servo axis, z=0 is aligned with the top
 * surface of the motor housing (axis extends into +z).
 * Horn origin is at the bottom of the horn, axis at x=y=0.
 *
 * To simplify the design of housings, use extrude_cable_connector > 0
 * and extrude_mounting_screws > 0 with d_mounting_screws set accordingly.
 *
 * 2021.11.14 - add TTLinker board
 * 2021.01.29 - SCS20 extrude_mounting_screws_heads
 * 2020.11.30 - fix SCS20 size (higher than SCS15!)
 * 2020.11.29 - updated brackets
 * 2020.11.23 - add SCS09 micro servo
 * 2020.11.21 - created (based on adafruit feedback servo)
 * 2019.02.18 - origninal adafruit feedback servo 
 *
 * (c) 2019, 2020 fnh, hendrich@informatik.uni-hamburg.de
 */

eps = 0.1;
fn  = 100;

feetech_demo = 1;

if (feetech_demo) {


translate( [  0, 0,   0] )  feetech_wing_servo();
translate( [ 80, 0, 0] )      feetech_standard_servo();
translate( [ 80, 0, 1.5+10] ) rotate( [0,180,0] ) feetech_servo_disc();

// translate( [  0, 0, 0] )   feetech_scs20_servo( extrude_mounting_screws=7, extrude_mounting_screws_heads=22 );
translate( [ -80,  80,   0] )  feetech_scs20_servo();
translate( [ -80,  0,   0] )  feetech_scs15_servo( extrude_21mm_axles=50, extrude_cable_connector=10 );
translate( [-160,  0,   0] )  feetech_scs09_servo();
translate( [   0,  0, -50] )  feetech_servo_double_end_disc();

translate( [ 160, 0, 0] )  feetech_scs_bracket_small();
translate( [ 160, 40, 0] ) feetech_scs_bracket_big();

translate( [ 0,80,0] )     adafruit_feedback_servo();
translate( [ 0,80,1.5] )   adafruit_feedback_servo_horn();
  
translate( [   0,150,0] )  servo_disc_adapter_plate();
translate( [  -20,150,0] ) cylinder( d=2.0, h=25.0, center=false );
translate( [   20,150,0] ) bottom_axle_adapter_plate( inbus_head_cut_depth = 1, servo_disc_cut_depth = 0.5 );
translate( [   40,150,0] ) bottom_axle_adapter_plate( bore=8.0, rim=1.0, make_m3_bores=0 );
translate( [  160, 80,0] ) ttlinker( hull=1, pin_length=5.0 );
}




/**
 * SCS20 digital  bus servo, double axis
 */
module feetech_scs20_servo(
  extrude_mounting_screws=2, 
  extrude_mounting_screws_heads=0, 
  d_mounting_screws=1.58,
  d_mounting_screws_heads=3.6,
  extrude_cable_connector=0,
  extrude_21mm_axles=0,
  body_color = [0.4,0.4,0.6],
) 
{
   // main housing 
   sx = 40.2;  // total width, including label stickers (main body 40.0)
   sy = 20.1;  // including label stickers, main body more like 20.0
   sz = 40.5;  // higher than SCS15 (!)
   
   sx_axis_rim = 12.5;
   sz_axis_rim = 1.4;
   dx_axis_rim = sx - 30.3;
  
   d_axle = 5.95; // 24T 25T ?
   h_axle = 4.3;

   sx_fins = 8.0; // size of the "mounting fins"
   sy_fins = sy;
   sz_fins = 2.5;
   dx_fins = sx_fins/2;
   dz_fins = -8.7; // from top surface of the body
   dx_fin_holes = (sx_fins - 4.65); // fron fin center!
   dy_fin_holes = (14.8 - 4.8)/2; // outer distance minus hole radius
   dd_fin_holes = 4.8;

   // axle
   color( "gold" )
   translate( [dx_axis_rim,0,-sz/2] )
     translate( [-dx_axis_rim ,0,sz/2+sz_axis_rim] ) 
       difference() {
         cylinder( d=d_axle, h=h_axle, $fn=fn, center= false );
         cylinder( d=2.5,    h=h_axle+eps, $fn=fn, center= false );
       }

   if (extrude_mounting_screws == 0) {
     color( "red" ) 
       translate( [dx_axis_rim+4,0,0] ) rotate( [0,0,90] ) 
         electronics_label( "FeeTECH", letter_size=3 );


     color( [0.95, 0.95, 0.95] ) 
       translate( [dx_axis_rim+8,0,0] ) rotate( [0,0,90] ) 
         electronics_label( "SCS-20", letter_size=2.5 );
   }
  
   translate( [dx_axis_rim,0,-sz/2] )
   {
     // main housing 
     difference() {
       color( body_color )
         cube( size=[sx, sy, sz], center=true );
       
       // side cable connector holes
       // color( "orange" ) 
       translate( [-5,-sy/2, -sz/2+7.5] )
         cube( [9.5, 2.0, 5.5], center=true );
       // color( "orange" ) 
       translate( [-5,+sy/2, -sz/2+7.5] )
         cube( [9.5, 2.0, 5.5], center=true );

     if (extrude_mounting_screws == 0) {
       // mounting screw holes (top)
       for( dy=[-8, +8] ) 
          for( dx=[-10+6.8] )
            translate( [dx, dy, sz/2] )
              cylinder( d=1.58, h=4.0, $fn=20, center=true );
       for( dy=[-7, +7] )
         translate( [sz/2-3-7, dy, sz/2] )
           cylinder( d=1.58, h=4.0, $fn=20, center=true );
       translate( [sz/2-3, 0, sz/2] )
         cylinder( d=1.58, h=4.0, $fn=20, center=true );
      
       // mounting screw holes (bottom), y distance 15, x distance 15 + 20
       for( dy=[-7.5,+7.5] ) {
          for( dx=[-17.5, +2.5, +17.5] )
            translate( [dx, dy,-sz/2] )
              cylinder( d=1.58, h=4.0, $fn=20, center=true );
        }
      }
     } // difference
     
     if (extrude_mounting_screws > 0) {
       // mounting screw holes (top)
       for( dy=[-8, +8] ) 
          for( dx=[-10+6.8] )
            translate( [dx, dy, sz/2] )
              cylinder( d=d_mounting_screws, h=extrude_mounting_screws, $fn=20, center=false );
          
       for( dy=[-7, +7] )
         translate( [sz/2-3-7, dy, sz/2-eps] )
           cylinder( d=d_mounting_screws, h=extrude_mounting_screws+1.4*eps, $fn=20, center=false );
       translate( [sz/2-3, 0, sz/2-eps] )
         cylinder( d=d_mounting_screws, h=extrude_mounting_screws+1.4*eps, $fn=20, center=false );
      
       // mounting screw holes (bottom), y distance 15, x distance 15 + 20
       for( dy=[-7.5,+7.5] ) {
          for( dx=[-17.5, +2.5, +17.5] )
            translate( [dx, dy,-sz/2-extrude_mounting_screws-eps] )
              cylinder( d=d_mounting_screws, h=extrude_mounting_screws+2*eps, $fn=20, center=false );
        }
      }
      
      if (extrude_mounting_screws_heads > 0) {
        // mounting screw holes (top)
        
        for( dy=[-8, +8] ) 
          for( dx=[-10+6.8] )
            translate( [dx, dy, sz/2+extrude_mounting_screws] )
              cylinder( d=d_mounting_screws_heads, h=extrude_mounting_screws_heads+eps, $fn=20, center=false );
      
        // three holes on bottom of front (driving) side
        for( dy=[-7, +7] )
          translate( [sz/2-3-7, dy, sz/2+extrude_mounting_screws-2*eps] )
            cylinder( d=d_mounting_screws_heads, h=extrude_mounting_screws_heads+2.5*eps, $fn=20, center=false );

        translate( [sz/2-3, 0, sz/2+extrude_mounting_screws-2*eps] )
          cylinder( d=d_mounting_screws_heads, h=extrude_mounting_screws_heads+2.5*eps, $fn=20, center=false );
      
        // mounting screw holes (bottom), y distance 15, x distance 15 + 20
        for( dy=[-7.5,+7.5] ) {
          for( dx=[-17.5, +2.5, +17.5] )
            translate( [dx, dy,-sz/2-extrude_mounting_screws-extrude_mounting_screws_heads+eps] )
              cylinder( d=d_mounting_screws_heads, h=extrude_mounting_screws_heads, $fn=20, center=false );
        }
     }


      
      if (extrude_21mm_axles > 0) {
        // 21mm wide extrusions on top and bottom side, aka "servo disc cutouts"
        color( [0.9, 0.4, 0.4, 0.3] ) 
          translate( [-dx_axis_rim,0,sz/2-eps] )
            cylinder( d=21.0, h=extrude_21mm_axles, $fn=fn, center=false ); 
        color( [0.9, 0.4, 0.4, 0.3] ) 
          translate( [-dx_axis_rim,0,-sz/2-extrude_21mm_axles+eps] )
            cylinder( d=21.0, h=extrude_21mm_axles, $fn=fn, center=false ); 
      }
      
      if (extrude_cable_connector > 0) {
       // side cable connector holes
       translate( [-5,-sy/2-extrude_cable_connector/2+eps, -sz/2+7.5] )
         color( "orange" ) 
         cube( [9.5, extrude_cable_connector, 5.5], center=true );
       translate( [-5,+sy/2+extrude_cable_connector/2-eps, -sz/2+7.5] )
         color( "orange" ) 
         cube( [9.5, extrude_cable_connector, 5.5], center=true );
      }

     // axis rim (top)
     color( [0.4,0.4,0.6] ) 
     translate( [-dx_axis_rim ,0,sz/2] ) cylinder( d=sx_axis_rim, h=sz_axis_rim, $fn=fn, center= false );
     
     // axis rim (bottom)
     color( [0.4,0.4,0.6] ) 
     translate( [-dx_axis_rim ,0,-sz/2-sz_axis_rim] ) cylinder( d=sx_axis_rim, h=sz_axis_rim, $fn=fn, center= false );
     
     // axis stub (bottom)
     color( [0.4,0.4,0.6] ) 
     translate( [-dx_axis_rim ,0,-sz/2-sz_axis_rim-4.0] ) 
       difference() {
         cylinder( d=6.2, h=4.0, $fn=fn, center=false );
         translate( [0,0,-eps] )
           cylinder( d=2.3, h=4.0, $fn=fn, center=false );
       }
   }
} // feetech_scs20_servo


/**
 * SCS15 digital bus servo, double axis
 */
module feetech_scs15_servo( 
  d_mounting_screws=1.58,
  d_mounting_screws_heads=3.0,
  extrude_mounting_screws=0, 
  extrude_mounting_screws_heads=0, 
  extrude_cable_connector=0,
  extrude_21mm_axles=0,
  body_color=[0.6,0.4,0.4],
) 
{
   // main housing 
   sx = 40.0;  // total width excluding screw-fins
   sy = 20.1;  // including label stickers, main body more like 20.0
   sz = 40.0;  
   
   sx_axis_rim = 12.5;
   sz_axis_rim = 1.4;
   dx_axis_rim = sx - 30.3;
  
   d_axle = 5.95; // 24T 25T ?
   h_axle = 4.3;

   sx_fins = 8.0; // size of the "mounting fins"
   sy_fins = sy;
   sz_fins = 2.5;
   dx_fins = sx_fins/2;
   dz_fins = -8.7; // from top surface of the body
   dx_fin_holes = (sx_fins - 4.65); // fron fin center!
   dy_fin_holes = (14.8 - 4.8)/2; // outer distance minus hole radius
   dd_fin_holes = 4.8;

   // axle
   color( "gold" )
   translate( [dx_axis_rim,0,-sz/2] )
     translate( [-dx_axis_rim ,0,sz/2+sz_axis_rim] ) 
       difference() {
         cylinder( d=d_axle, h=h_axle, $fn=fn, center= false );
         cylinder( d=2.5,    h=h_axle+eps, $fn=fn, center= false );
       }

   if (extrude_mounting_screws == 0) {
     color( "red" ) 
       translate( [dx_axis_rim+4,0,0] ) rotate( [0,0,90] ) 
         electronics_label( "FeeTECH", letter_size=3 );

     color( [0.95, 0.95, 0.95] ) 
       translate( [dx_axis_rim+8,0,0] ) rotate( [0,0,90] ) 
         electronics_label( "SCS-15", letter_size=2.5 );
   }
  
   translate( [dx_axis_rim,0,-sz/2] )
   {
     // main housing 
     difference() {
       color( body_color )
       cube( size=[sx, sy, sz], center=true );
       
      if (extrude_mounting_screws == 0) {
       // side cable connector holes
       translate( [-5,-sy/2, -sz/2+7.5] )
         cube( [9.5, 2.0, 5.5], center=true );
       translate( [-5,+sy/2, -sz/2+7.5] )
         cube( [9.5, 2.0, 5.5], center=true );
       
       // mounting screw holes (top)
       for( dy=[-8, +8] ) 
          for( dx=[-10+6.8] )
            translate( [dx, dy, sz/2] )
              cylinder( d=1.58, h=4.0, $fn=20, center=true );
       for( dy=[-7, +7] )
         translate( [sz/2-3-7, dy, sz/2] )
           cylinder( d=1.58, h=4.0, $fn=20, center=true );
       translate( [sz/2-3, 0, sz/2] )
         cylinder( d=1.58, h=4.0, $fn=20, center=true );
      
       // mounting screw holes (bottom), y distance 15, x distance 15 + 20
       for( dy=[-7.5,+7.5] ) {
          for( dx=[-17.5, +2.5, +17.5] )
            translate( [dx, dy,-sz/2] )
              cylinder( d=1.58, h=4.0, $fn=20, center=true );
       }
      } // if extrude_mounting_screws
     } // difference
     
     if (extrude_mounting_screws > 0) {
       // mounting screw holes (top)
       for( dy=[-8, +8] ) 
          for( dx=[-10+6.8] )
            translate( [dx, dy, sz/2] )
              cylinder( d=d_mounting_screws, h=extrude_mounting_screws, $fn=20, center=false );
          
       for( dy=[-7, +7] )
         translate( [sz/2-3-7, dy, sz/2-eps] )
           cylinder( d=d_mounting_screws, h=extrude_mounting_screws, $fn=20, center=false );
       translate( [sz/2-3, 0, sz/2-eps] )
         cylinder( d=d_mounting_screws, h=extrude_mounting_screws, $fn=20, center=false );
      
       // mounting screw holes (bottom), y distance 15, x distance 15 + 20
       for( dy=[-7.5,+7.5] ) {
          for( dx=[-17.5, +2.5, +17.5] )
            translate( [dx, dy,-sz/2-extrude_mounting_screws+eps] )
              cylinder( d=d_mounting_screws, h=extrude_mounting_screws, $fn=20, center=false );
        }
     }

     
     if (extrude_21mm_axles > 0) {
       // 21mm wide extrusions on top and bottom side, aka "servo disc cutouts"
       color( [0.9, 0.4, 0.4, 0.3] ) 
         translate( [-dx_axis_rim,0,sz/2-eps] )
           cylinder( d=21.0, h=extrude_21mm_axles, $fn=fn, center=false ); 
       color( [0.9, 0.4, 0.4, 0.3] ) 
         translate( [-dx_axis_rim,0,-sz/2-extrude_21mm_axles+eps] )
            cylinder( d=21.0, h=extrude_21mm_axles, $fn=fn, center=false ); 
     }
     
     if (extrude_cable_connector > 0) {
       // side cable connector holes
       translate( [-5,-sy/2-extrude_cable_connector/2+eps, -sz/2+7.5] )
         color( "orange" )
         cube( [9.5, extrude_cable_connector, 5.5], center=true );
       translate( [-5,+sy/2+extrude_cable_connector/2-eps, -sz/2+7.5] )
         color( "orange" )
         cube( [9.5, extrude_cable_connector, 5.5], center=true );
      }

     // axis rim (top)
     color( [0.6,0.4,0.4] ) 
     translate( [-dx_axis_rim ,0,sz/2] ) cylinder( d=sx_axis_rim, h=sz_axis_rim, $fn=fn, center= false );
     
     // axis rim (bottom)
     color( [0.6,0.4,0.4] ) 
     translate( [-dx_axis_rim ,0,-sz/2-sz_axis_rim] ) cylinder( d=sx_axis_rim, h=sz_axis_rim, $fn=fn, center= false );
     
     // axis stub (bottom)
     color( [0.6,0.4,0.4] ) 
     translate( [-dx_axis_rim ,0,-sz/2-sz_axis_rim-4.0] ) 
       difference() {
         cylinder( d=6.2, h=4.0, $fn=fn, center=false );
         translate( [0,0,-eps] )
           cylinder( d=2.3, h=4.0, $fn=fn, center=false );
       }
   }
} // feetech_scs15_servo


/**
 * SCS09 digital bus servo (mini servo, standard single axis).
 */
module feetech_scs09_servo(
  extrude_mounting_screws=0, 
  d_mounting_screws=1.58,
  extrude_cable_connector=2,
) 
{
   // main housing 
   sx = 23.4; // over cable-housing, 23.2 for main body
   sy = 12.4; // 
   sz = 21.6;  
   
   sx_axis_rim = 11.9;
   sz_axis_rim = 3.7;
   dx_axis_rim = 6.0;
  
   d_axle = 4.0; // 24T 25T ?
   h_axle = 2.95;

   sx_fins = 4.5; // size of the "mounting fins"
   sy_fins = sy;
   sz_fins = 1.6;
   dx_fins = sx_fins/2;
   dz_fins = -2.5; // from top surface of the body
  
   dx_fin_holes = 2.8; // fron main body
   dy_fin_holes = 0.0; 
   dd_fin_holes = 1.8;

   // axle
   color( "gold" )
     translate( [dx_axis_rim,0,-sz/2] ) {
       translate( [-dx_axis_rim ,0,sz/2+sz_axis_rim] ) 
         difference() {
           cylinder( d=d_axle, h=h_axle, $fn=fn, center= false );
           cylinder( d=2.5,    h=h_axle+eps, $fn=fn, center= false );
         }
   }

   color( "red" ) 
     translate( [dx_axis_rim+4,0,0] ) rotate( [0,0,90] ) 
       electronics_label( "FeeTECH", letter_size=1.5 );

   color( [0.95, 0.95, 0.95] ) 
     translate( [dx_axis_rim+8,0,0] ) rotate( [0,0,90] ) 
       electronics_label( "SCS-09", letter_size=2.0 );
  
   
   translate( [dx_axis_rim,0,-sz/2] )
   {
     // main housing 
     difference() {
       color( [0.4,0.4,0.6] ) 
       union() {
         // main housing body
         cube( size=[sx, sy, sz], center=true );
         
         // left and right mounting fins
         translate( [-sx/2-sx_fins/2, 0, sz/2+dz_fins-sz_fins/2] )
           cube( size=[sx_fins,sy,sz_fins], center=true );
         translate( [sx/2+sx_fins/2, 0, sz/2+dz_fins-sz_fins/2] )
           cube( size=[sx_fins,sy,sz_fins], center=true );
       }
       
       // mounting screw holes (top)
       for( dx=[-sx/2-dx_fin_holes, sx/2+dx_fin_holes] ) {
         dy_fin_holes = 0.0; // outer distance minus hole radius
         dd_fin_holes = 1.9;
         translate( [dx, 0, sz/2+dz_fins-sz_fins/2] )
           cylinder( d=d_mounting_screws, h=sz_fins+eps, $fn=20, center=true );
       }
          
     } // difference

     if (extrude_mounting_screws > 0) {
       for( dx=[-sx/2-dx_fin_holes, sx/2+dx_fin_holes] ) {
         dy_fin_holes = 0.0; // outer distance minus hole radius
         dd_fin_holes = 1.9;
         translate( [dx, 0, sz/2+dz_fins-sz_fins/2] )
           cylinder( d=d_mounting_screws, h=extrude_mounting_screws, $fn=20, center=true );
       }
     }
      
     // axis rim (top)
     color( [0.4,0.4,0.6] ) 
       translate( [-dx_axis_rim ,0,sz/2] ) cylinder( d=sx_axis_rim, h=sz_axis_rim, $fn=fn, center= false );
     
    }
   
  if (extrude_cable_connector > 0) {
    translate( [dx_axis_rim,0,-sz/2] )
      // bottom cable 
       color( "orange" )
       translate( [sx/2-1,0, -sz/2-extrude_cable_connector] )
         cube( [1.5, 3.72, 5.5], center=true );
  }

} // feetech_scs09_servo




/**
 * SCS small bracket (fits the SCS15/SCS20 servo body).
 */
module feetech_scs_bracket_small()
{
  color( [0.9, 0.9, 0.9] ) {
    // bottom/connecting plate
    difference() {
      translate( [0,0,1] )
        cube( [44, 20, 2], center=true ); 
      cylinder( d=6.2, h=5, $fn=fn, center=true );
      
      // xy distance: 10 mm, 45 deg: d=14.4, r=7.0 datasheet (measured 7.2)
      for( theta=[0,90,180,270] ) {
        rotate( [0,0,theta+45] ) translate( [7.0,0,0] ) 
          cylinder( d=3.0, h=5, $fn=20, center=true );
      }
    }
    // rectangular side plate (connects to bottom side of servo)
    translate( [21, 0, 26.8/2] )
      difference() {
        cube( [2, 20, 26.8], center=true ); 

        translate( [0,0,26.8/2-10.2] ) 
          rotate( [0,90,0] ) 
            cylinder( d=8.0, h=4.0, $fn=50, center=true );
        
        // 2x2 array of thin bores d=2.0 on bottom side of the servo
        translate( [0,0,26.8/2-10.2] ) 
        for( dy=[-7.5,+7.5] )
          for( dz=[-7.5, +7.5] )
            translate( [0, dy, dz] ) rotate( [0,90,0] ) 
              cylinder( d=2.0, h=5, $fn=20, center=true );
      }
    // rounded side plate (connects to small bores on top side of servo) 
    translate( [-21, 0, 26.8/2] )
      difference() {
        union() {
          // cube( [2, 20, 26.8], center=true ); 
          translate( [0,0,-26.8/2+(26.8-10.2)*0.5] ) 
            cube( [2, 20, 26.8-10.2], center=true );
          
          translate( [0,0,26.8/2-10.2] ) 
            rotate( [0,90,0] ) 
            cylinder( d=20, h=2.0, $fn=fn, center=true );
        }

        translate( [0,0,26.8/2-10.2] ) 
          rotate( [0,90,0] ) 
            cylinder( d=8.0, h=4.0, $fn=50, center=true );

        // 4 small bores (d=2.0) for mounting screws on top side of servo
        translate( [0,0,26.8/2-10.2] ) 
        for( theta=[0,90,180,270] )
          rotate( [theta,0,0] ) translate( [0, 0, 7.0] )
            rotate( [0,90,0] ) 
              cylinder( d=2.0, h=5, $fn=20, center=true );
      }
  }
}


/**
 * SCS big servo bracket (without rounded corners / bevels).
 * Fits the SCS15/SCS20 output axle(s).
 */
module feetech_scs_bracket_big()
{
  color( [0.9, 0.9, 0.9] ) {
    // bottom/connecting part
    difference() {
      translate( [0,0,1] )
        cube( [55.3, 20, 2], center=true ); 
      
      cylinder( d=6.0, h=5, $fn=fn, center=true );
      
      // xy distance 10mm, diagonal d=14.4 r=7.2
      for( dx=[-15, -5, +5, +15] )
        for( dy=[-5, +5] )
          translate( [dx, dy, 0] )
            cylinder( d=3.0, h=5, $fn=20, center=true );
    }

    // sides
    for( dx=[-55.3/2, +55.3/2] ) {
      translate( [dx, 0, 0] ) 
      difference() {
        z_bore_center = 23.4 + 8.0/2; // 8mm bore
        union() {
          translate( [0,0, z_bore_center/2] ) 
            cube( [2, 20, z_bore_center], center=true );
          translate( [0, 0, z_bore_center] ) 
            rotate( [0,90,0] ) 
              cylinder( d=20, h=2.0, $fn=fn, center=true );
        }

        translate( [0, 0, z_bore_center] ) 
          rotate( [0,90,0] ) 
            cylinder( d=8.0, h=4.0, $fn=50, center=true );

        translate( [0,0, z_bore_center] ) 
        for( theta=[0,90,135,180,225,270] )
          rotate( [theta,0,0] ) 
            translate( [0, 0, 7.2] )
              rotate( [0,90,0] ) 
                cylinder( d=3.0, h=5, $fn=20, center=true );
      }
    }
  }
} // feetech_servo_bracket_big


module feetech_standard_servo() 
{
     // main housing 
   sx = 39.8; // total width excluding screw-fins
   sy = 20.06; // bottom plate, main body more like 20.0
   sz = 38.7;  
   
   sx_axis_rim = 12.5;
   sz_axis_rim = 0.5;
   dx_axis_rim = sx - 30.3;
  
   d_axle = 5.95; // 24T 25T ?
   h_axle = 4.5;

   sx_fins = 8.0; // size of the "mounting fins"
   sy_fins = sy;
   sz_fins = 2.5;
   dx_fins = sx_fins/2;
   dz_fins = -8.7; // from top surface of the body
   dx_fin_holes = (sx_fins - 4.65); // fron fin center!
   dy_fin_holes = (14.8 - 4.8)/2; // outer distance minus hole radius
   dd_fin_holes = 4.8;

   // axle
   color( "gold" )
   translate( [dx_axis_rim,0,-sz/2] )
     translate( [-dx_axis_rim ,0,sz/2+sz_axis_rim] ) 
       difference() {
         cylinder( d=d_axle, h=h_axle, $fn=fn, center= false );
         cylinder( d=2.5,    h=h_axle+eps, $fn=fn, center= false );
       }

   color( "red" ) 
     translate( [dx_axis_rim+4,0,0] ) rotate( [0,0,90] ) 
       electronics_label( "FeeTECH", letter_size=3 );

   color( [0.95, 0.95, 0.95] ) 
     translate( [dx_axis_rim+8,0,0] ) rotate( [0,0,90] ) 
       electronics_label( "FS5113R", letter_size=2.5 );
  
   color( [0.5,0.5,0.5] ) 
   translate( [dx_axis_rim,0,-sz/2] )
   union() {
     // main housing with one diagonal edge
     difference() {
       cube( size=[sx, sy, sz], center=true );
       translate( [sx/2, 0, sz/2] ) rotate( [0,0,0] )
         cube( size=[10,sy+eps,4], center=true );
     }
     // axis rim
     translate( [-dx_axis_rim ,0,sz/2] ) cylinder( d=sx_axis_rim, h=sz_axis_rim, $fn=fn, center= false );
     
     
     // left mounting fins
     translate( [-dx_fins-sx/2, 0, sz/2+dz_fins] )
       difference() {
         cube( size=[sx_fins, sy_fins, sz_fins], center=true );
         translate( [-dx_fin_holes/2, -dy_fin_holes, -sz_fins/2-eps] )
           cylinder( d=dd_fin_holes, h=sz_fins+2*eps, $fn=fn, center=false );
         translate( [-dx_fin_holes/2, +dy_fin_holes, -sz_fins/2-eps] )
           cylinder( d=dd_fin_holes, h=sz_fins+2*eps, $fn=fn, center=false );
     }
     // right mounting fins
     translate( [+dx_fins+sx/2, 0, sz/2+dz_fins] )
       difference() {
         cube( size=[sx_fins, sy_fins, sz_fins], center=true );
         translate( [dx_fin_holes/2, -dy_fin_holes, -sz_fins/2-eps] )
           cylinder( d=dd_fin_holes, h=sz_fins+2*eps, $fn=fn, center=false );
         translate( [dx_fin_holes/2, +dy_fin_holes, -sz_fins/2-eps] )
           cylinder( d=dd_fin_holes, h=sz_fins+2*eps, $fn=fn, center=false );
     }
     // cable outlet, simplified as a (too thick) cylinder
     translate( [-sx/2,0,-sz/2+5.0] ) 
       scale( [1,1,0.5] ) 
         rotate( [0,-90,0] ) 
           cylinder( d=7, h=7, $fn=fn, center=false );
   }
} // feetech_standard_servo


module feetech_wing_servo() 
{
     // main housing 
   sx = 29.9; // total width excluding screw-fins
   sy = 10.0; // bottom plate, main body more like 20.0
   sz = 35.5;  

   sx_axis_rim = 0; // 30-23.4;
   sz_axis_rim = 0.5;
   dx_axis_rim = sx - 23.4;

  
   d_axle = 5.95; // 24T 25T ?
   h_axle = 3.5;

   sx_fins = 8.0; // size of the "mounting fins"
   sy_fins = sy;
   sz_fins = 2.5;
   dx_fins = sx_fins/2;
   dz_fins = -8.7; // from top surface of the body
   dx_fin_holes = (sx_fins - 4.65); // fron fin center!
   dy_fin_holes = (14.8 - 4.8)/2; // outer distance minus hole radius
   dd_fin_holes = 4.8;


   // axle
   color( "gold" )
   translate( [dx_axis_rim,0,-sz/2] )
     translate( [-dx_axis_rim ,0,sz/2+sz_axis_rim] ) 
       difference() {
         cylinder( d=d_axle, h=h_axle, $fn=fn, center= false );
         cylinder( d=2.5,    h=h_axle+eps, $fn=fn, center= false );
       }

   color( "red" ) 
     translate( [dx_axis_rim+3,2,0] ) rotate( [0,0,0] ) 
       electronics_label( "FeeTECH", letter_size=2 );

   color( [0.95, 0.95, 0.95] ) 
     translate( [dx_axis_rim+3,-2,0] ) rotate( [0,0,0] ) 
       electronics_label( "FT3325M", letter_size=2 );
  
   translate( [dx_axis_rim,0,-sz/2] )
   union() {
     // main housing 
     difference() {
       color( [0.5,0.5,0.5] ) 
       cube( size=[sx, sy, sz], center=true );
     }
     // axis rim
     translate( [-dx_axis_rim ,0,sz/2] ) cylinder( d=sx_axis_rim, h=sz_axis_rim, $fn=fn, center= false );

     // cable outlet, simplified as a (too thick) cylinder
     color( "orange" ) 
     translate( [-sx/2,0,0] ) 
       scale( [1,0.4,1] ) 
         rotate( [0,-90,0] ) 
           cylinder( d=6, h=5, $fn=fn, center=false );
   }

   // upper mounting fins (together)
   translate( [dx_axis_rim, 0, -4-eps] ) rotate( [90,0,0] ) 
   difference() {
     hull() {
       rr = 1.5;
       for( dx = [ -42/2+rr, +42/2-rr ] )
         for( dy = [ -4+rr, +4-rr ] ) 
           translate( [dx,dy,0] ) cylinder( r=rr, h=2+eps, center=true, $fn=20 );
     }
     // M3 bores
     for( ddx = [-36/2, 36/2 ] ) 
       translate( [ ddx, 0, 0] ) cylinder( d=3, h=2+1, center=true, $fn=30 );
   }

   // bottom mounting fin
   translate( [dx_axis_rim, 0, -sz-3-eps] ) rotate( [90,0,0] ) 
   difference() {
     hull() {
       rr = 1.5;
       for( dx = [ -5+rr, +5-rr ] )
         for( dy = [ -3+rr, +3 ] ) 
           translate( [dx,dy,0] ) cylinder( r=rr, h=2+eps, center=true, $fn=20 );
     }
     // M3 bores
     translate( [ 0, 0, 0] ) cylinder( d=3, h=2+1, center=true, $fn=30 );
   }


} // feetech_wing_servo




/**
 * servo horn/aluminium disc delivered with SCS15/SCS20 servos:
 * outer diameter 20.0mm, main plate height 2.5mm, total height 4.5mm,
 * four M2.5 bores spaced 90 degrees, radius 7.0mm.
 */
module feetech_servo_disc( 
  extrude_screws_length=10,     // M2.5 bore length
  extrude_screws_head=[2,7,5.4]  // distance to front, length, diameter
)
{
  color( [0.9, 0.9, 0.9] ) 
  difference() {
    union() {
      cylinder( d=20.0, h=2.50, $fn=fn, center=false );
      translate( [0,0,2.5] )
        cylinder( d=9.0, h=2.0, $fn=fn, center=false );
    }
    translate( [0,0,0.5] )
      cylinder( d=5.5, h=4.1+eps, $fn=fn, center=false );
    translate( [0,0,-eps] )
      cylinder( d=3.2, h=4.7, $fn=fn, center=false );

    for( theta=[0,90,180,270] ) {
      rotate( [0,0,theta] ) 
        translate( [7.0,0,-eps] )
          cylinder( d=2.5, h=2.7, $fn=fn, center=false );
    }
  } // difference
    
  if (extrude_screws_length > 0) { 
    for( theta=[0,90,180,270] ) {
      rotate( [0,0,theta] ) 
        translate( [7.0,0,2-extrude_screws_length-eps] )
          cylinder( d=2.5, h=extrude_screws_length+2, $fn=fn, center=false );
    }
  }
  if (len(extrude_screws_head) == 3) {
    for( theta=[0,90,180,270] ) {
      rotate( [0,0,theta] ) 
        translate( [7.0,0,-extrude_screws_head[0]-extrude_screws_head[1]-eps] )
          cylinder( d=extrude_screws_head[2], h=extrude_screws_head[1], $fn=fn, center=false );
    }
    
  }
    
    
}


/**
 * the free-turning joint for the bottom-end of the SCS servos;
 * outer diameter 20mm, axle bore 6.1mm, disc thickness 2.1mm.
 * Inner rim has outer diameter 9.0mm, height 1.1 mm,
 * four M2.5 bores spaced 90 degrees, radius 7.0mm.
 */
module feetech_servo_double_end_disc(
  d_disk = 20.0,
  d_axle =  6.2,
  d_ring =  9.0,
  h_disk =  2.1,
  h_disk_offset = 1.0,
  h_ring =  1.1,
) 
{
  color( [0.9, 0.9, 0.9] ) 
  difference() {
    union() {
      cylinder( d=d_disk, h=h_disk, $fn=fn, center=false );
      translate( [0,0,0] ) 
        cylinder( d=d_ring, h=h_disk+h_ring, $fn=fn, center=false );
    }
    
    translate( [0,0,-eps] )
      cylinder( d=d_axle, h=h_disk+h_ring+2*eps, $fn=fn, center=false );

    // screw bore xy-distance 10.0mm, diagonal 14.4mm, radius 7.0mm
    for( theta=[0,90,180,270] ) {
      rotate( [0,0,theta] ) 
        translate( [7.0,0,-eps] )
          cylinder( d=2.5, h=h_disk+2*eps, $fn=fn, center=false );
    }
  }  
}






/**
 * generic adapter plate for FeeTech SCS servo 25T discs (d=20mm),
 * with 8 screw bores (spaced 45 degrees) around axle,
 * given plate thickness and overall height. Axle is at (height-10) mm.
 * Optionally, inbus screw head cavities are cut into the plate.
 */
module servo_disc_adapter_plate(
  thickness = 3.0, // overall thickness of plate
  height = 25.0,
  inbus_head_cut_depth = 1, // optional cavities for M3 inbus screws
  servo_disc_cut_depth = 0.5, // optional drive side cutout for disc
  servo_disc_cut_diameter = 20.0+0.5,
)
{
  if (height < 25.0) 
    echo( "WARNING: servo_disc_adapter_plate height too small: ", height );
  
  if ((thickness - inbus_head_cut_depth - servo_disc_cut_depth) < 1.0) 
    echo( "WARNING: servo_disc_adapter_plate thickness (after cutting) too small",
           thickness - inbus_head_cut_depth + servo_disc_cut_depth );
  

  z_bore_center = height-10.0; // 8mm bore
  
  // cylinder( d=1, h=100, center=true );
  difference() {
    union() {
      translate( [0,0, z_bore_center/2] ) 
        cube( [thickness, 20, z_bore_center], center=true );
      translate( [0, 0, z_bore_center] ) 
        rotate( [0,90,0] ) 
          cylinder( d=20, h=thickness, $fn=fn, center=true );
    }

    translate( [0, 0, z_bore_center] ) 
      rotate( [0,90,0] ) 
        cylinder( d=8.0, h=thickness+1.0, $fn=50, center=true );
    
    if (servo_disc_cut_depth > 0) {
      translate( [thickness/2-servo_disc_cut_depth, 0, z_bore_center] )
        rotate( [0,90,0] ) 
          cylinder( d=servo_disc_cut_diameter, h=2*servo_disc_cut_depth+eps, $fn=fn, center=true );
    }

    translate( [0,0, z_bore_center] ) {
      // for( theta=[0,90,135,180,225,270] ) { // feetech bracket has 6 bores only
      for( theta=[0,45,90,135,180,225,270,315] ) {
        rotate( [theta,0,0] ) 
          translate( [0, 0, 7.2] )
            rotate( [0,90,0] ) 
              cylinder( d=3.0, h=thickness+1, $fn=20, center=true );
        if (inbus_head_cut_depth > 0) {
          rotate( [theta,0,0] ) 
            translate( [-thickness/2-eps, 0, 7.2] )
              rotate( [0,90,0] ) 
                cylinder( d=5.0, h=inbus_head_cut_depth, $fn=20, center=false );
        } // if
      } // for
    } // translate
    
  } // difference
}


/**
 * generic adapter plate for FeeTech SCS servo bottom axle
 * with given plate thickness and overall height. Axle is at (height-10) mm.
 * Use increased bore (default 6.0mm) when mounting distance rings or
 * ball bearings w/o rim.
 */
module bottom_axle_adapter_plate(
  thickness = 3.0, // overall thickness of plate
  height = 25.0,
  make_m3_bores = 1,
  inbus_head_cut_depth = 0, // optional cavities for M3 inbus screws
  servo_disc_cut_depth = 0, // optional drive side cutout for disc
  bore = 6.0,
  rim = 1.0
)
{
  if (height < 25.0) 
    echo( "WARNING: bottom_axle_adapter_plate height too small: ", height );
  
  if (thickness < 1.0) 
    echo( "WARNING: servo_disc_adapter_plate thickness (after cutting) too small",
           thickness );

  z_bore_center = height-10.0; // 6mm bore
  
  difference() {
    union() {
      translate( [0,0, z_bore_center/2] ) 
        cube( [thickness, 20, z_bore_center], center=true );
      translate( [0, 0, z_bore_center] ) 
        rotate( [0,90,0] ) 
          cylinder( d=20, h=thickness, $fn=fn, center=true );
    }

    translate( [0, 0, z_bore_center] ) 
      rotate( [0,90,0] ) 
        cylinder( d=bore, h=thickness+1.0, $fn=fn, center=true );
    
    if (rim > 0) {
      translate( [-thickness/2-eps, 0, z_bore_center] ) 
        rotate( [0,90,0] ) 
          cylinder( d=bore+2*rim, h=rim, $fn=fn, center=false );
    }
    
    if (servo_disc_cut_depth > 0) {
      translate( [-thickness/2+servo_disc_cut_depth, 0, z_bore_center] )
        rotate( [0,90,0] ) 
          cylinder( d=20+eps, h=2*servo_disc_cut_depth+eps, $fn=fn, center=true );
    }

    if (make_m3_bores == 1) 
    translate( [0,0, z_bore_center] ) {
      // for( theta=[0,90,135,180,225,270] ) { // feetech bracket has 6 bores only
      for( theta=[0,45,90,135,180,225,270,315] ) {
        rotate( [theta,0,0] ) 
          translate( [0, 0, 7.2] )
            rotate( [0,90,0] ) 
              cylinder( d=3.0, h=thickness+1, $fn=20, center=true );
        if (inbus_head_cut_depth > 0) {
          rotate( [theta,0,0] ) 
            translate( [thickness/2-inbus_head_cut_depth+eps, 0, 7.2] )
              rotate( [0,90,0] ) 
                cylinder( d=5.0, h=inbus_head_cut_depth, $fn=20, center=false );
        } // if
      } // for
    } // translate
    
  } // difference
}

 
 
module adafruit_feedback_servo()
{
   // main housing 
   sx = 39.5; // total width excluding screw-fins
   sy = 19.6; // bottom plate, main body more like 19.5
   sz = 38.5;  
   
   sx_axis_rim = 11.8;
   sz_axis_rim = 1.0;
   dx_axis_rim = sx - 30.3;

   sx_fins = 8.0; // size of the "mounting fins"
   sy_fins = sy;
   sz_fins = 2.5;
   dx_fins = sx_fins/2;
   dz_fins = -8.7; // from top surface of the body
   dx_fin_holes = (sx_fins - 4.65); // fron fin center!
   dy_fin_holes = (14.8 - 4.8)/2; // outer distance minus hole radius
   dd_fin_holes = 4.8;
  
   color( [0.5,0.5,0.5] ) 
   translate( [dx_axis_rim,0,-sz/2] )
   union() {
     // main housing with one diagonal edge
     difference() {
       cube( size=[sx, sy, sz], center=true );
       translate( [sx/2, 0, sz/2] ) rotate( [0,45,0] )
         cube( size=[10,sy+eps,8], center=true );
     }
     // axis rim
     translate( [-dx_axis_rim ,0,sz/2] ) cylinder( d=sx_axis_rim, h=sz_axis_rim, $fn=fn, center= false );
     
     // left mounting fins
     translate( [-dx_fins-sx/2, 0, sz/2+dz_fins] )
       difference() {
         cube( size=[sx_fins, sy_fins, sz_fins], center=true );
         translate( [-dx_fin_holes/2, -dy_fin_holes, -sz_fins/2-eps] )
           cylinder( d=dd_fin_holes, h=sz_fins+2*eps, $fn=fn, center=false );
         translate( [-dx_fin_holes/2, +dy_fin_holes, -sz_fins/2-eps] )
           cylinder( d=dd_fin_holes, h=sz_fins+2*eps, $fn=fn, center=false );
     }
     // right mounting fins
     translate( [+dx_fins+sx/2, 0, sz/2+dz_fins] )
       difference() {
         cube( size=[sx_fins, sy_fins, sz_fins], center=true );
         translate( [dx_fin_holes/2, -dy_fin_holes, -sz_fins/2-eps] )
           cylinder( d=dd_fin_holes, h=sz_fins+2*eps, $fn=fn, center=false );
         translate( [dx_fin_holes/2, +dy_fin_holes, -sz_fins/2-eps] )
           cylinder( d=dd_fin_holes, h=sz_fins+2*eps, $fn=fn, center=false );
     }
     // cable outlet, simplified as a (too thick) cylinder
     translate( [-sx/2,0,-sz/2+5.0] )
       rotate( [0,-90,0] ) 
         cylinder( d=7, h=7, $fn=fn, center=false );
   }
     
   
 }
 
 
module adafruit_feedback_servo_horn() {
   sx = 47.4;
   sy = 11.3;
   sz =  2.5; 
   z2 =  3.9; // stem height
   d2 =  9.9; // stem diameter
   d3 =  5.9; // estimated diameter at the ends 
   
   db =  1.5; // estimated hole bore
   r1 = 11.9; // from axis to inner hole
   r5 = 20.8; // from axis to outer hole
   
   cylinder( d=d2, h=z2, center=false, $fn=fn );
   translate( [0,0,z2] ) difference() {
     hull() {
       cylinder( d=sy, h=sz, center=false, $fn=fn );
       translate( [ sx/2-d3/2,0,0] ) cylinder( d=d3, h=sz, center=false, $fn=fn );
       translate( [-sx/2+d3/2,0,0] ) cylinder( d=d3, h=sz, center=false, $fn=fn );
     }
     dr = (r5 - r1) / 4;
     for ( r = [r1 : dr : r5+eps] ) {
       translate( [-r,0,-eps] ) cylinder( d=db, h=z2+2*eps, center=false, $fn=fn );
       translate( [ r,0,-eps] ) cylinder( d=db, h=z2+2*eps, center=false, $fn=fn );
     }
     // translate( [-r1,0,-eps] ) cylinder( d=db, h=z2+2*eps, center=false, $fn=fn );
     // translate( [-r5,0,-eps] ) cylinder( d=db, h=z2+2*eps, center=false, $fn=fn );
  } 
}

/**
 * Feetech FE-TTlinker-mini, RS232-to-RS485 (half-duplex) interface.
 * Origin at bottom center (note bottom is foam).
 */
module ttlinker( hull=1, pin_length=5.0 )
{
  w_pcb = 21.0; w_molex = 10.0;
  l_pcb = 30.0; l_total = 35.3; l_molex = 8.0; l_molex_upper = 5.5;
  l_pin = 7.5;
  h_pcb = 1.2;  h_foam = 2.3; h_molex = 5.5; h_total = 9;
  difference() {
    union() {
      color( [0.1, 0.1, 0.1] ) 
        translate( [0,0,h_foam/2] ) 
          cube( [l_pcb-1, w_pcb-1, h_foam], center = true ); // foam
      color( "darkgreen" )
        translate( [0,0,h_foam+h_pcb/2+0.] )
          cube( [l_pcb, w_pcb, h_pcb], center = true ); // main PCB
        
      color( "white" )  
        translate( [l_pcb/2+2.0,w_molex/2+0.1,h_total-h_molex/2] )
          cube( [l_molex_upper, w_molex, h_molex], center = true ); // main PCB
      color( "white" )  
        translate( [l_pcb/2+2.0,-w_molex/2-0.1,h_total-h_molex/2] )
          cube( [l_molex_upper, w_molex, h_molex], center = true ); // main PCB
      color( "black" )
        translate( [3,w_pcb/2-4,h_foam+h_pcb+3] ) rotate( [0,90,0] )
          cylinder( d=5.2, h=11.5, center=true, $fn=30 );
      color( "black" )
        translate( [-l_pcb/2+3.5,0,h_foam+h_pcb+1.27] ) rotate( [0,90,0] )
          cube( [2.54,7*2.54,2.54], center=true );
        
      y = [-3*2.54, -2*2.54, 0, 1*2.54, 2*2.54, 3*2.54];
      cols = ["black", "red", "orange", "green", "red", "black" ];
      dims = [ 1.0, 1.0, 1.0, 1.0, 1.5, 1.5 ];
      lbls = [ "GND", "+5V", "TX1", "RX0", "VMOT", "GND" ];
      for( i=[0:len(cols)-1] ) {
        echo( "y pin= ", y[i] );
        color( cols[i] )
          translate( [-l_pcb/2+3.5,y[i],h_foam+h_pcb] ) 
            cylinder( d=dims[i], h=4.0, center=false, $fn=17 );
        color( cols[i] ) // "silver" 
          translate( [-l_pcb/2+3.5,y[i],h_foam+h_pcb+2.54+1.27] ) rotate( [0,-90,0] )
            cylinder( d=dims[i], h=l_pin, center=false, $fn=17 );
        color( "gold" ) 
          translate( [-l_pcb/2+5.5, y[i], h_foam+h_pcb+0.2] ) 
            electronics_label( lbls[i], halign="left" );
      } // for

      fy = [ -3, -2, -1, +1, +2, +3 ];
      cols2 = ["black", "red", "yellow", "black", "red", "yellow" ];
      for( i=[0:len(cols)-1] ) {
        echo( "y pin= ", y[i] );
        color( cols2[i] ) // or "silver" 
          translate( [l_pcb/2, fy[i]*2.54,h_foam+h_pcb+2.54] ) rotate( [0,90,0] )
            cylinder( d=1.0, h=6.0, center=false, $fn=17 );
      } // for
      

      
    } // union
  } // difference
}
 
 
 

module electronics_label( string, letter_size=1.5, halign = "center", valign = "center" ) {
  font = "Liberation Sans";
	// Use linear_extrude() to make the letters 3D objects as they
	// are only 2D shapes when only using text()
	linear_extrude(height = 0.2) {
		text( string, size = letter_size, font = font, halign = halign, valign = valign, $fn = 16);
	}
}
 
 