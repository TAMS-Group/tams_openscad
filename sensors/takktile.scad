/** takktile.scad 
 *
 * Simple mechanical/housing models of Takktile/Takkstrip2 sensors,
 * originally manufactured by Righthandrobotics.
 *
 * All units in millimeters, use corresponding scale() to convert
 * to meters etc.
 * 
 * 2023.06.29 - created
 * 
 * (c) 2023 fnh, hendrich@informatik.uni-hamburg.de
 */
 

eps = 0.05;
fn = 150;


translate( [20,0,0] )   takkstrip2( cables=[] );
translate(  [0,0,0] )   takktile_single( cables=[] );
translate( [10,0,0] )   takktile_single( cables=[7,7,3] );
translate( [-20,0,0] )  takktile_triple( cables=[6,8,1] );
translate( [-10,0,0] )  MPL115A2();


/** one Takkstrip2 module consisting of one 1x3 and three 1x1 takktile sensors
    (on the front) and one ATtiny used as i2c-multiplexer on the back.
    
    Origin is at the bottom center of the circuit board,
 */
module takkstrip2( cables=[] )
{
  // circuit board with one 1x3 module and 3 1x1 modules.
  // 
  translate( [0,12,0] )  takktile_triple( cables=cables, _fn=15 );
  translate( [0,-4,0] )  takktile_single( cables=[], _fn=15 );  
  translate( [0,-12,0] ) takktile_single( cables=[], _fn=15 );  
  translate( [0,-20,0] ) takktile_single( cables=[], _fn=15 );  
}


module takktile_single( cables=[], _fn=30 )
{
  // circuit board
  ww = 8.0; ll = 8.0; hh = 1.3;
  color( "darkred" )
  translate( [0,0,hh/2] )
    cube( [ww, ll, hh], center=true );
  
  // barometer chip
  translate( [0,0,hh] )
    MPL115A2( _fn=_fn );  
    
  // polyurethan shell
  sx = 6.0; sy = 6.0; sz = 2.5;
  color( "gold", 0.7 )
  translate( [0,0,hh+sz/2+eps] )
    cube( [sx, sy, sz], center=true );
    
  // I2C connector/electrodes
  color( "silver" )
  for( i=[0:4] ) // C-D-V-G-S: clock data vcc gnd chip-select
    translate( [0, -2*1.27+i*1.27, 0] )
      cube( [ 2.5, 0.5, 0.5], center=true );
    
    
  // optional cable box, if any
  if (len(cables) == 3) {
    echo( "CABLES: ", cables );   
    color( "pink", 0.5 )
    translate( [0,0,-cables[2]/2+eps] )
      cube( [cables[0], cables[1], cables[2]], center=true );
  }
}

module takktile_triple( cables=[], _fn=30 ) 
{
  // circuit board
  ww = 8.0; ll = 3*8.0; hh = 1.3;
  color( "darkred" )
  translate( [0,0,hh/2] )
    cube( [ww, ll, hh], center=true );
  
  // barometer chip
  translate( [0,0,hh] )
    MPL115A2( _fn=_fn );  
  translate( [0,-8,hh] )
    MPL115A2( _fn=_fn );  
  translate( [0,+8,hh] )
    MPL115A2( _fn=_fn );  
    
  // polyurethan shell
  sx = 6.0; sy = 2*8+6.0; sz = 2.5;
  color( "gold", 0.7 )
  translate( [0,0,hh+sz/2+eps] )
    cube( [sx, sy, sz], center=true );
    
  // ATtiny on back side
  tx = 4.0; ty = 4.0; tz = 0.6;
  color( "black" )
  translate( [0,-4,-tz/2] )
    cube( [tx, ty, tz], center=true );
    
  // I2C connector/electrodes: S6 S5 S4 clock data VCC GND
  color( "silver" )
  for( i=[0:6] )
    translate( [0, 3.5+i*1.27, 0] )
      cube( [ 2.5, 0.5, 0.5], center=true );
    
  // optional cable box, if any
  if (len(cables) == 3) {
    echo( "CABLES: ", cables );   
    color( "pink", 0.5 )
    translate( [0,8,-cables[2]/2+eps] )
      cube( [cables[0], cables[1], cables[2]], center=true );
  }
}


/** 
 * 3D model of the Freescale MPL115A2 air-pressure sensor
 */
module MPL115A2( _fn=20 ) 
{
  r = 0.5; h = 1.2; w = 3.0; l = 5.0;
   
  color( "silver" )
  translate( [0,0,0.1] )
    cube( [ 3.0, 5.0, 0.2 ], center=true );

  difference() {    
    color( "silver" ) 
    hull() { // outer body
      for( dx=[-2.65/2+r, 2.65/2-r ] ) {
        for( dy=[-4.65/2+r, 4.65/2-r] ) {
          translate( [dx, dy, 0] ) cylinder( r=r, h=0.5, center=false, $fn=_fn );
          translate( [dx, dy, 1.2-r] ) sphere( r=r, $fn=_fn );
        }
      }
    } // hull
    // venting hole    
    translate( [0, -5.0/2 + 1.3, h] )
      cylinder( d=1.0, h=1.0, center=true, $fn=_fn );
  }   
  
  // footprint + pads
  for( dy=[-1.25-0.625,-0.625, 0.625, 0.625+1.25] ) {
    for( dx=[-1,+1] ) {
      translate( [dx, dy, 0] ) 
        cube( [0.8, 0.5, eps], center=true );
    }
  }
}



 

  
// ################################################################



module electronics_label( string, letter_size=1.5, halign="center", valign="center" ) {
  font = "Liberation Sans";
	// Use linear_extrude() to make the letters 3D objects as they
	// are only 2D shapes when only using text()
	linear_extrude(height = 0.2) {
		text( string, size = letter_size, font = font, halign = halign, valign = valign, $fn = 16);
	}
}


module arduino_blue() {
  color( [0,0,0.5] ) children();
}


module teensy_green() {
  color( [0,0.4,0] ) children();
}


module black() {
  color( [0,0,0] ) children();
}


module copper() {
  color( [0.95, 0.7, 0.3] ) children();
} 

 
module silver() {
   color( [0.9,0.9,0.9] ) children(); 
}

