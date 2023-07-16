/** simplified mesh for the Facebook DIGIT tactile sensor.
 * 
 * (c) 2022, fnh, hendrich@informatik.uni-hamburg.de
 */
 
 digit_sensor();
 
 
 /**
  * simplified model of the DIGIT sensor.
  * Sensor points towards +x, origin is at the bottom.
  */
 module digit_sensor( usb_connector=[20,15,8], M2_bore=2.2 ) {
   w = 26.5;
   h = 32.4;  // without top ridge
   hh = 33.7; // with ridge  
   l  = 28.5; // without gel
   ll = 32.3; // with gel
   gw = 18.2; // gel width
   gh = 24.6; // gel height
   ss = 10.0; // distance between screws
   sl = 15.0; // screw center from back face
   rb =  2.0; // bottom bevel radius
   uh =  5.0; 
   uw =  9.9;
   ur =  2.0;
   ul =  4.0;

   rc = w/2;  // radius of main housing
   rd = gw/2; // top radius of gel
   re = 1;    // bottom radius of gel part
   border = (w - gw) / 2;

   color( [0.5,0.1,0.1,0.8] )    
   translate( [-sl,0,0] ) 
   difference() {
     hull() {
       translate( [0,+w/2-rb,rb] ) 
         rotate( [0,90,0] ) 
           cylinder( r=rb, h=l, center=false, $fn=30 );
       translate( [0,-w/2+rb,rb] ) 
         rotate( [0,90,0] ) 
           cylinder( r=rb, h=l, center=false, $fn=30 );
       translate( [0,0,h-rc] ) 
         rotate( [0,90,0] ) 
           cylinder( r=rc, h=l, center=false, $fn=30 );
     }
     
     // mounting screws
     translate( [sl, +ss/2, -0.1] ) cylinder( d=M2_bore, h=4, center=false, $fn=20 );
     translate( [sl, -ss/2, -0.1] ) cylinder( d=M2_bore, h=4, center=false, $fn=20 );
   }
   
   color( "white" )
   translate( [-sl,0,0] ) 
   hull() {
     translate( [l,+gw/2-re,border+re] ) 
       rotate( [0,90,0] ) 
         cylinder( r=re, h=ll-l-0.5, center=false, $fn=30 );
     translate( [l,-gw/2+re,border+re] ) 
       rotate( [0,90,0] ) 
         cylinder( r=re, h=ll-l-0.4, center=false, $fn=30 );
     translate( [l,0,h-border-rd] ) 
       rotate( [0,90,0] ) 
         cylinder( r=rd, h=ll-l-0.4, center=false, $fn=30 );
     translate( [ll-8,0,border] )
       cylinder( r=8, h=gh-5, center=false, $fn=100 );
   }
   
   // usb plug
   color( "blue" )
   hull() {
     translate( [-sl-0.1,-uw/2,uh] ) 
       rotate( [0,90,0] ) 
         cylinder( r=ur, h=ul, center=false, $fn=30 );
     translate( [-sl-0.1,+uw/2,uh] ) 
       rotate( [0,90,0] ) 
         cylinder( r=ur, h=ul, center=false, $fn=30 );
   }
   
   // usb connector (if non-zero)
   if (len(usb_connector) == 3) {
     color( "orange" )
     translate( [-sl-usb_connector[0]/2, 0,uh] ) 
       cube( size=usb_connector, center=true );
   }
}
 