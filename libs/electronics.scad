/** electronics.scad 
 *
 * Simple mechanical/housing models of common electronic parts.
 * All units in millimeters, use corresponding scale() to convert
 * to meters etc.
 * 
 * 2023.07.07 - add GY-280
 * 2020.07.06 - add TSSOP packages
 * 2020.06.10 - add 'wire_hull' option for the DIL/DPIP packages
 * 2020.06.09 - add standard SMD packages (1206, 0805, Panasonic spec)
 * 2020.06.09 - add 'SOIC' package (parameters according to Microchip spec)
 * 2020.06.09 - add 'DIL' package (with tilted/flat pins as an option)
 * 2020.01.09 - add 'pro micro' and HE5B deadman switch
 * 2019.08.11 - add arduino_nano33iot
 * 2018.01.08 - add 'headers' and 'bores' options
 * 2018.01.05 - created (copy ATtiny etc from previous other files)
 * 
 * (c) 2018, 2020, 2023 fnh, hendrich@informatik.uni-hamburg.de
 */
 

translate( [80,75,0] )  raspberry_pico(  screws=[], headers=[5,3], hull=false );
translate( [120,20,0] ) gy_521();
translate( [120,40,0] ) gy_271();
translate( [120,0,0] )  gy_bmp280( hull=0, pin_lengths=[4,2] );


if (1) translate( [-100,-30,0] ) 
{ // pushbutton demo
translate( [0*12.7,0,0] )
pushbutton( bcolor=[1,1,0], bh=3.0, wlength=10, wdiam=1.5 ); // bcolor=[1,0,0], hull = false );
translate( [1*12.7,0,0] )
pushbutton( bcolor=[1,0.5,0], bh=4.0, wlength=10, wdiam=1.5 ); // bcolor=[1,0,0], hull = false );
translate( [2*12.7,0,0] )
pushbutton( bcolor=[1,0,0], bh=5.0, wlength=10, wdiam=1.5 ); // bcolor=[1,0,0], hull = false );
translate( [3*12.70,0,0] )
pushbutton( bcolor=[0.2,0.2,0.2], bh=7.0, wlength=10, wdiam=1.5 ); // bcolor=[1,0,0], hull = false );
}


/**
 * SCAD model of the "round type" pushbutton sold by Reichelt de.
 * One contact only, normally open. Two plastic alignment pins.
 * Button cap height bh: yellow 3.0mm, orange 4.0m, red 5.0mm, black 7.0mm
 */
module pushbutton( bcolor=[0.9,0.9,0.1], bh=4.0, dw=8.5/2, wdiam=0.6, wlength=3.2, hull=false )
{
  sx = 12.7; sy = 12.7; sz = 3.6; // main body size
  bd =  9.6;  // button disk diameter
    
  color( "black" )
  translate( [0,0,sz/2] ) 
    cube( [sx, sy, sz], center=true );
  color( "black" )
  translate( [0,0,sz] )
    cylinder( d=7.0, h=1.0, center=false, $fn=30 );
    
  color( bcolor )
  translate( [0,0,sz+1] )
    cylinder( d=bd, h=bh, center=false, $fn=200 );
    
  // contact pins
  color( "silver" ) {
    translate( [0,0,-wlength/2] )
      cylinder( d=wdiam, h=wlength, center=true, $fn=30 );
    translate( [dw,dw,-wlength/2] )
      cylinder( d=wdiam, h=wlength, center=true, $fn=30 );
  }

  // "knubbel" 
  color( "gray" ) {  
    translate( [+dw,-dw,-2.4/2] )
      cylinder( d=1.3, h=2.4, center=true, $fn=30 );
    translate( [-dw,+dw,-2.4/2] )
      cylinder( d=1.3, h=2.4, center=true, $fn=30 );
  }
}
 
eps = 0.05;
fn = 150;

if (true) {
electronics_demo();
pdip_package_demo();
soic_package_demo();
tssop_package_demo();

translate( [-4*2.54, 5*2.54, 0] ) smd_package_demo();
translate( [-8*2.54, 5*2.54, 0] ) axial_resistor_demo();
translate( [-10*2.54, 0, 0] ) pin_header( n_pins = 10, pitch = 2.54, h =2.0 );


translate( [120, -25, 0] ) 
  debo4in1( pin_lengths=[3,1], hull=0, labels=1, coords=1 );
}  
  


/**
 * Bosch BMP-280 (or BME-280) breakout with switchable I2C or SPI
 * interface.
 */
module gy_bmp280( 
  hull = 1, labels = 1, pin_lengths=[4,2] 
)
{
  w = 15.0; h = 11.5; t = 1.6; // board size
  difference() {
    union() {
      // breakout/circuit board
      color( "darkred" )
      translate( [0,0,t/2] ) 
        cube( size=[w, h, t], center=true );
      
      // BME/BMP-280 chip
      translate( [0,h/2-2.92-1.7/2,t+0.5] ) 
      difference() {
        silver()
        cube( size=[2.4, 1.7, 1.0], center=true );
        translate( [0.7, -0.3, 1.0] ) 
          cylinder( d=0.5, h=1, center=true, $fn=20 );
      }
      // large capacitor
      color( "orange" )
      translate( [0,h/2-1.5, t+0.5] ) 
        cube( size=[2, 1, 1], center=true );

      // metal contacts around contact bores      
      for( i=[0:5] ) {
        silver() 
        translate( [ (i-2.5)*2.54, -h/2+1.5, -1*eps] ) 
          cylinder( d=2.1, h=t+2*eps, center=false, $fn=20 );
      }
    }    

    // mounting bores M3
    M3 = 3.2; xbore = 7.0/2 + M3/2; ybore = h/2-1.2-M3/2;
  
    if (hull == 0) {
    for( dx=[-xbore, +xbore] )
      translate( [dx, ybore, -eps] )
        cylinder( d=M3, h=t+2*eps, center=false, $fn=50 );
    }

    // contact bores (VCC GND SCL SDA XDA XCL AD0 SEL)
    if (hull == 0) {
      for( i=[0:5] ) {
        translate( [ (i-2.5)*2.54, -h/2+1.5, -2*eps] ) 
          cylinder( d=1.5, h=t+6*eps, center=false, $fn=20 );
      }
    }

    dx = 12.6/2 + 1.5;   
    dy = 1.1 + 1.5;
  }
  
  if (len( pin_lengths ) >= 2) {
    if (pin_lengths[1] > 0)
    for( i=[0:5] ) {
          silver()
          translate( [ (i-2.5)*2.54, -h/2+1.5, -pin_lengths[1]] ) 
            cylinder( d=1, h=pin_lengths[1], center=false, $fn=20 );
    }
  }  
  if (len( pin_lengths ) >= 1) {
    if (pin_lengths[0] > 0)
    for( i=[0:5] ) {
          silver()
          translate( [ (i-2.5)*2.54, -h/2+1.5, 0] ) 
            cylinder( d=1, h=t+pin_lengths[0], center=false, $fn=20 );
    }
  }

  if (hull > 0) {
    translate( [0,-h/2+1.5,-hull/2] )
      cube( [w,3+eps,hull+eps], center=true ); 
    translate( [0,-h/2+1.5, t+hull/2] )
      cube( [w,3+eps,hull+eps], center=true ); 
  }

  if (labels != 0) {
    // labels on front side
    translate( [0, -1, t-0.15 ] ) 
      electronics_label( "GY-280" );
  
    // labels on backside
    translate( [0, 3, 0.15 ] ) rotate( [0,180,0] ) 
      electronics_label( "GY-280" );
    translate( [0, 0, 0.15 ] ) rotate( [0,180,0] ) 
      electronics_label( "air pressure" );
  }
} // end module gy_bme280



/**
 * GY-271 / QMC883 3-axis digital compass with I2C interface
 */
module gy_271( 
  hull = 0, labels = 1, pin_lengths=[4,2] 
)
{
  w = 13.30; h = 14.3; t = 1.6; // board size
  difference() {
    union() {
      // breakout/circuit board
      color( "darkred" )
      translate( [0,0,t/2] ) 
        cube( size=[w, h, t], center=true );
      
      // BME/BMP-280 chip
      translate( [w/2-4,h/2-4,t+0.45] ) 
      difference() {
        black()
        cube( size=[3, 3, 0.9], center=true );
        translate( [0.7, -0.3, 1.0] ) 
          cylinder( d=0.5, h=1, center=true, $fn=20 );
      }
      // large capacitor
      color( "orange" )
      translate( [-w/2+2.5,h/2-2.5, t+0.5] ) 
        cube( size=[1, 2, 1], center=true );

      // metal contacts around contact bores      
      for( i=[0:4] ) {
        silver() 
        translate( [ (i-2)*2.54, -h/2+1.5, -1*eps] ) 
          cylinder( d=2.1, h=t+2*eps, center=false, $fn=20 );
      }
    }    


    // contact bores (VCC GND SCL SDA XDA XCL AD0 SEL)
    if (hull == 0) {
      for( i=[0:4] ) {
        translate( [ (i-2)*2.54, -h/2+1.5, -2*eps] ) 
          cylinder( d=1.5, h=t+6*eps, center=false, $fn=20 );
      }
    }

    dx = 12.6/2 + 1.5;   
    dy = 1.1 + 1.5;
  }
  
  if (len( pin_lengths ) >= 2) {
    if (pin_lengths[1] > 0)
    for( i=[0:4] ) {
          silver()
          translate( [ (i-2)*2.54, -h/2+1.5, -pin_lengths[1]] ) 
            cylinder( d=1, h=pin_lengths[1], center=false, $fn=20 );
    }
  }  
  if (len( pin_lengths ) >= 1) {
    if (pin_lengths[0] > 0)
    for( i=[0:4] ) {
          silver()
          translate( [ (i-2)*2.54, -h/2+1.5, 0] ) 
            cylinder( d=1, h=t+pin_lengths[0], center=false, $fn=20 );
    }
  }

  if (hull > 0) {
    translate( [0,-h/2+1.5,-hull/2] )
      cube( [w,3+eps,hull+eps], center=true ); 
    translate( [0,0, t+hull/2] )
      cube( [w,h,hull+eps], center=true ); 
  }

  if (labels != 0) {
    // labels on front side
    translate( [0, -1, t-0.15 ] ) 
      electronics_label( "GY-271" );
  
    // labels on backside
    translate( [0, 3, 0.15 ] ) rotate( [0,180,0] ) 
      electronics_label( "GY-271" );
    translate( [0, 0, 0.15 ] ) rotate( [0,180,0] ) 
      electronics_label( "compass" );
  }
  
} // end module gy_271





/**
 * GY-521 breakout with Invensense 6-axis MPU 6050 IMU.
 */
module gy_521( 
  hull = 1, labels = 1, coords = 1, pin_lengths=[4,2] 
)
{
  w = 21.0; h = 16.0; t = 1.6; // board size
  difference() {
    union() {
      // breakout/circuit board
      arduino_blue()
      translate( [0,0,t/2] ) 
        cube( size=[w, h, t], center=true );
      
      // IMU chip
      black()
      translate( [0,0,t+0.6] ) 
        cube( size=[4, 4, 1.2], center=true );

      // large capacitor
      color( "orange" )
      translate( [0,5,t+0.5] ) 
        cube( size=[3, 1, 1], center=true );

      // metal contacts around contact bores      
      for( i=[0:7] ) {
        silver() 
        translate( [ (i-3.5)*2.54, -h/2+1.5, -1*eps] ) 
          cylinder( d=2.1, h=t+2*eps, center=false, $fn=20 );
      }
    }    

    // contact bores (VCC GND SCL SDA XDA XCL AD0 SEL)
    if (hull == 0) {
      for( i=[0:7] ) {
        translate( [ (i-3.5)*2.54, -h/2+1.5, -2*eps] ) 
          cylinder( d=1.5, h=t+6*eps, center=false, $fn=20 );
      }
    }

    dx = 12.6/2 + 1.5;   
    dy = 1.1 + 1.5;

    // M3 mounting bores
    if (hull == 0) {
      for( ddx=[-dx, +dx] ) {
        translate( [ddx, h/2-dy, -eps] )
          cylinder( d=3.1, h=t+2*eps, center=false, $fn=50 );
      }
    }
  }
  
  if (len( pin_lengths ) >= 2) {
    if (pin_lengths[1] > 0)
    for( i=[0:7] ) {
          silver()
          translate( [ (i-3.5)*2.54, -h/2+1.5, -pin_lengths[1]] ) 
            cylinder( d=1, h=pin_lengths[1], center=false, $fn=20 );
    }
  }  
  if (len( pin_lengths ) >= 1) {
    if (pin_lengths[0] > 0)
    for( i=[0:7] ) {
          silver()
          translate( [ (i-3.5)*2.54, -h/2+1.5, 0] ) 
            cylinder( d=1, h=t+pin_lengths[0], center=false, $fn=20 );
    }
  }

  if (hull > 0) {
    translate( [0,-h/2+1.5,-hull/2] )
      cube( [w,3+eps,hull+eps], center=true ); 
  }

  if (labels != 0) {
    // labels on front side
    translate( [0, 7, t-0.15 ] ) 
      electronics_label( "GY-521" );
  
    // labels on backside
    translate( [0, 3, 0.15 ] ) rotate( [0,180,0] ) 
      electronics_label( "GY-521" );
    translate( [0, 0, 0.15 ] ) rotate( [0,180,0] ) 
      electronics_label( "6-DOF MPU-6050" );
  }
  
  if (coords != 0) {
    color( "red" ) translate( [8,-3,t] ) rotate( [-90,0,0] ) 
      cylinder( d=1, h=4, center=false, $fn=20 ); // +x-axis
    color( "red" ) translate( [8,2.3,t] ) 
      electronics_label( "+X   " );
    color( "green" ) translate( [8,-3,t] ) rotate( [0,-90,0] ) 
      cylinder( d=1, h=4, center=false, $fn=20 ); // +x-axis
    color( "green" ) translate( [2.5,-3,t] )
      electronics_label( "+Y" );
  }
} // end module gy_521







/**
 * USB->LiPo->5V charger and step-up regulator board,
 * four on-board LEDs to indicate battery level
 */
module debo4in1( 
  hull = true, labels = 1, coords = 1, pin_lengths=[4,2] 
)
{
  w = 25.3; h = 16.2; t = 1.6; // board size
  
  xs = [5.0, 8.0]; ys = [5.6, 5.6];  
    
  difference() {
    union() {
      // breakout/circuit board
      arduino_blue()
      translate( [0,0,t/2] ) 
        cube( size=[w, h, t], center=true );
      
      // step-up converter / lipo charger chip
      color( "black" )
      translate( [5,0,t+0.6] ) 
        cube( size=[4, 6, 1.2], center=true );

      // large capacitor
      color( "orange" )
      translate( [-3,0,t+0.5] ) 
        cube( size=[7,7,3], center=true );
        
      // four indicator LEDs
      for( i=[0:3] ) {
        color( "yellow" )
          translate( [ w/2-2.0, (i-1.0)*1.5, t+0.2] ) 
            cube( [2,1,0.4], center=true );
      }

      // metal contacts around contact bores      
      for( i=[0:5] ) {
        silver() 
        translate( [ -w/2+3/2+0.5, (i-2.5)*2.54, t] ) 
          cube( [3,2,0.1], center=true );
      }
      
      // metal contacts for power-on-off switch
      for( i=[0:len(xs)-1] ) {
        silver()
        translate( [xs[i], ys[i], t] ) 
          cylinder( d=1.5, h=0.1, center=false, $fn=40 );
      }
    }    

    // contact bores (VCC GND SCL SDA XDA XCL AD0 SEL)
    if (hull == 0) {
      for( i=[0:5] ) {
        translate( [ -w/2+3/2+0.5, (i-2.5)*2.54, -eps] ) 
          cylinder( d=1, h=t+1, center=false, $fn=40 );
      }
      
      for( i=[0:len(xs)-1] ) {
        silver()
        translate( [xs[i], ys[i], -eps] ) 
          cylinder( d=1.0, h=t+1, center=false, $fn=40 );
      }

    }

    dx = 12.6/2 + 1.5;   
    dy = 1.1 + 1.5;

  }
  
  if (len( pin_lengths ) >= 2) {
    if (pin_lengths[1] > 0) {
      for( i=[0:5] ) {
        translate( [ -w/2+3/2+0.5, (i-2.5)*2.54, -eps] ) 
          cylinder( d=0.8, h=t+1, center=false, $fn=40 );
      }
    }
    
    for( i=[0:len(xs)-1] ) {
        translate( [xs[i], ys[i], -eps] ) 
          cylinder( d=1.0, h=t+1, center=false, $fn=40 );
      }

  }  

  if (hull > 0) {
    translate( [0,-h/2+1.5,-hull/2] )
      cube( [w,3+eps,hull+eps], center=true ); 
  }

  if (labels != 0) {
    // labels on front side
    translate( [0, 7, t-0.15 ] ) 
      electronics_label( "4-in-1" );
  
    // labels on backside
    translate( [0, 3, 0.15 ] ) rotate( [0,180,0] ) 
      electronics_label( "4in1" );
    translate( [0, 0, 0.15 ] ) rotate( [0,180,0] ) 
      electronics_label( "6-DOF MPU-6050" );
  }
  
} // end debo4in1











module axial_resistor_demo() {
  dx = 2.54; dy = 2.54;
  translate( [dx, 0*dy, 0] ) axial_resistor( rings=[1,0,0,10] );
  translate( [dx, 1*dy, 0] ) axial_resistor( rings=[2,2,1,11] );
  translate( [dx, 2*dy, 0] ) axial_resistor( rings=[3,3,2,0] );
  translate( [dx, 3*dy, 0] ) axial_resistor( rings=[4,7,3,10] );
  translate( [dx, 5*dy, 0] ) axial_resistor( rings=[5,6,4,10], d=3, wd=1         );
}

module tssop_package_demo() {
  dx = -20*2.54; dy = 6*2.54;
  translate( [3.5*dx,0*dy,0] ) tssop_package( n_pins= 8, name="555", phi=4 );
  translate( [3.5*dx,1*dy,0] ) tssop_package( n_pins=20, name="7400", phi=8 );
  translate( [3.5*dx,2*dy,0] ) tssop_package( n_pins=28, name="TI9548" );
}


/**
 * pin-header oriented along +x, with the first pin at (0,0,0),
 * and the actual pin protruding downwards (-z).
 */
module pin_header(
  n_pins = 10,
  pitch  = 2.54, // 0.1 inch is typical
  h      = 2.5,
  housing_color = [0,0,0],
  pin_color = "silver",
  pin_length = 3.0,
) 
{
  for( i=[0:n_pins-1] ) {
    difference() {
      translate( [i*pitch, 0, h/2] ) 
        color( housing_color )
          cube( size=[pitch,pitch,h], center=true ); 
      
      translate( [i*pitch, 0, 1] ) 
        color( pin_color ) 
          cylinder( d=0.6*pitch, h=h-1+2*eps, center=false, $fn=20 );
    }
    translate( [i*pitch, 0, -pin_length+eps] )   
      color( pin_color )
        cylinder( d=0.5, h=pin_length, center=false, $fn=20 );  
  } // for
}



module axial_resistor( 
  rings = [7,2,4,11], // [0..9, 0..9, 0..9, 0..11
  labl = "470k",
  quality="10%", 
  l=5.0, d=2.0,     // main body length and diameter
  wl=10, wd=0.7, ww=1 // wire length, diameter, wire angle distance
)
{
  colors = ["black", "brown",
            "red", "orange", "yellow",
            "blue", "green", "purple",
            "gray", [0.9,0.9,0.9], "silver", "gold" ];
  
  
  translate( [0,0,d/2] ) 
    rotate( [0,90,0] ) {
      dd = l/9; hh = l/7;
      color( [0.7, 0.5, 0.3] )
        cylinder( d=d, h=l, center=true, $fn=50 );
      // 4 ring color code
      color( colors[rings[0]] )
        translate( [0,0,-3*dd] ) cylinder( d=d+eps, h=hh, center=true, $fn=50 );
      color( colors[rings[1]] )
        translate( [0,0,-dd] ) cylinder( d=d+eps, h=hh, center=true, $fn=50 );
      color( colors[rings[2]] )
        translate( [0,0,+dd] ) cylinder( d=d+eps, h=hh, center=true, $fn=50 );
      color( colors[rings[3]] )
        translate( [0,0,+3*dd] ) cylinder( d=d+eps, h=hh, center=true, $fn=50 );
      // central part of the wire
      color( "silver" )
        cylinder( d=wd, h=l+2*ww, center=true, $fn=50 );
      translate( [0,0,-l/2-ww] ) color( "silver" )
        sphere( d=wd, $fn=50 );
      translate( [0,0,l/2+ww] ) color( "silver" )
      color( "silver" )
        sphere( d=wd, $fn=50 );
    }
  translate( [l/2+ww, 0, d/2] ) rotate( [0,180,0] ) 
    cylinder( d=wd, h=wl/2-ww, center=false, $fn=50 );
  translate( [-l/2-ww, 0, d/2] ) rotate( [0,180,0] ) 
    cylinder( d=wd, h=wl/2-ww, center=false, $fn=50 );
   
}



/**
 * Panasonic thick-film chip resistors:
 * https://s3.amazonaws.com/s3-blogs.mentor.com/tom-hausherr/files/2010/07/thin-film-resistors.jpg
 */
module smd_package_demo() {
  dx = 2.54; dy = 3*2.54;
  // translate( [4*dx,0*dy,0] ) smd_package_generic();
  translate( [dx,0.0*dy,0] ) smd_2512_package(); 
  translate( [dx,0.5*dy,0] ) smd_2010_package(); 
  translate( [dx,1.0*dy,0] ) smd_1812_package(); 
  translate( [dx,1.5*dy,0] ) smd_1210_package(); 
  translate( [dx,2.0*dy,0] ) smd_1206_package(); 
  translate( [dx,2.5*dy,0] ) smd_1008_package(); 
  translate( [dx,3.0*dy,0] ) smd_0805_package(); 
  translate( [dx,3.5*dy,0] ) smd_0603_package(); 
  translate( [dx,4.0*dy,0] ) smd_0402_package(); 
  translate( [dx,4.2*dy,0] ) smd_0201_package(); 
  translate( [dx,4.4*dy,0] ) smd_01005_package(); 
}

module smd_package_generic( // default is 01005
  L = 0.4, // device length
  W = 0.2, // device width
  a = 0.1, // electrode corner cutout
  b = 0.1, // footprint length
  t = 0.13, // object height
  ccolor = [0,0.7,0.1], 
  mass = 0.04
) 
{
  color( ccolor ) 
  translate( [0,0, t/2] )
    cube( size=[L, W, t], center=true );
  translate( [L/2-b/2+0.01, 0, t/2] )
    cube( size=[b, W-a, t+0.01], center=true );
  translate( [-L/2+b/2-0.01, 0, t/2] )
    cube( size=[b, W-a, t+0.01], center=true );
}


module smd_2512_package() 
{
  smd_package_generic( L=6.4, W=3.2, t=0.65, a=0.6, b=0.6 );
}

module smd_2010_package() 
{
  smd_package_generic( L=5.0, W=2.5, t=0.6, a=0.5, b=0.5 );
}

module smd_1812_package() 
{
  smd_package_generic( L=4.5, W=3.2, t=0.6, a=0.5, b=0.5 );
}

module smd_1210_package() 
{
  smd_package_generic( L=3.2, W=2.5, t=0.6, a=0.5, b=0.5 );
}

module smd_1206_package() 
{
  smd_package_generic( L=3.2, W=1.6, t=0.6, a=0.5, b=0.5 );
}

module smd_1008_package() 
{
  smd_package_generic( L=2.5, W=2.0, t=0.6, a=0.4, b=0.4 );
}

module smd_0805_package() 
{
  smd_package_generic( L=2.0, W=1.25, t=0.6, a=0.4, b=0.4 );
}

module smd_0603_package() 
{
  smd_package_generic( L=1.6, W=0.80, t=0.45, a=0.3, b=0.3 );
}

module smd_0402_package() 
{
  smd_package_generic( L=1.0, W=0.50, t=0.35, a=0.2, b=0.25 );
}

module smd_0201_package() 
{
  smd_package_generic( L=0.6, W=0.30, t=0.23, a=0.1, b=0.15 );
}

module smd_01005_package() 
{
  smd_package_generic( L=0.4, W=0.20, t=0.13, a=0.1, b=0.10 );
}



module soic_package_demo() {
  dx = -20*2.54; dy = 6*2.54;
  translate( [3*dx,0*dy,0] ) soic_package( n_pins= 8, name="555", phi=4 );
  translate( [3*dx,1*dy,0] ) soic_package( n_pins=14, name="7400", phi=8 );
  translate( [3*dx,2*dy,0] ) soic_package( n_pins=16, name="150mil16" );

  translate( [3*dx,3*dy,0] ) 
    soic_package( n_pins=8, name="208mil8", 
                  p = 1.27, A = 1.97, A2 = 1.88, A1 = 0.13, E = 7.96, E1 = 5.28,
                  D = 5.21, h = 0.50, L = 0.64, phi = 4,
                  c = 0.23, B = 0.43, alpha = 12, beta= 12 );

  translate( [3*dx,4*dy,0] ) 
    soic_package( n_pins=20, name="300mil20", 
                  p = 1.27, A = 2.50, A2 = 2.31, A1 = 0.2, E = 10.34, E1 = 7.49,
                  D = 12.80, h = 0.50, L = 0.84, phi = 4,
                  c = 0.28, B = 0.42, alpha = 12, beta= 12 );
  
}


module soic_package(
  n_pins = 16, 
  name   = "hugo",
  p      = 1.27, // pin pitch 
  A      = 1.55, // overall height
  A2     = 1.42, // molded package thickness
  A1     = 0.18, // standoff height above footprint/pcb
  E      = 6.02, // overall width,
  E1     = 3.92, // molded package width,
  D      = 4.90, // overall length
  h      = 0.38, // chamfer distance
  L      = 0.62, // foot length
  phi    = 4,    // font angle (degrees)
  c      = 0.23, // lead thickness
  B      = 0.42, // lead width
  alpha  = 12,   // mold draft angle top
  beta   = 12,   // mold draft angle bottom
)
{
  D = n_pins/2 * p;
  
  translate( [0,0,A1+A2/2] ) {
    difference() {
      color( [0.2, 0.2, 0.2] )
        cube( size=[D, E1, A2], center=true );
      translate( [-D/2+0.8, -E1/2+1, A1+A2-1.2] ) // pin 1 marker
        cylinder( d=1, h=3, center=false, $fn=20 );
    }
   
    // etch-on the name
    translate( [0,0,A2/2-eps] ) 
      electronics_label( name, letter_size=1.0 );
  }
  
  imin = -n_pins/4;
  imax = (n_pins/4)-1;
  for( i=[imin:imax] ) {
    translate( [i*p+p/2, E/2-L/2, c/2] ) rotate( [-phi,0,0] ) 
      color( "silver" )
        cube( size=[B,L,c], center=true );
    translate( [i*p+p/2, -E/2+L/2, c/2] ) rotate( [phi,0,0] ) 
      color( "silver" )
        cube( size=[B,L,c], center=true );
    
    // height of inner part of the wires is NOT specified,
    // we assume A/2
    translate( [i*p+p/2, 0, A1+A2/2] ) 
      color( "silver" )
        cube( size=[B,E-2*L,c], center=true );
    
    // interpolating wire pieces
    translate( [i*p+p/2, -E/2+L, A1+A2/4] ) rotate( [75,0,0] ) 
      color( "silver" )
        cube( size=[B,A/2,c], center=true );
    translate( [i*p+p/2, +E/2-L, A1+A2/4] ) rotate( [-75,0,0] ) 
      color( "silver" )
        cube( size=[B,A/2,c], center=true );
    
  }
}


module tssop_package(
  n_pins = 20, 
  name   = "tssop20-thin-plastic-shrink-small-outine",
  p      = 0.65, // pin pitch 
  A      = 1.10, // overall height
  A2     = 0.90, // molded package thickness
  A1     = 0.10, // standoff height above footprint/pcb
  E      = 6.38, // overall width,
  E1     = 4.40, // molded package width,
  D      = 6.50, // overall length
  h      = 0.38, // chamfer distance
  L      = 0.60, // foot length
  phi    = 4,    // font angle (degrees)
  c      = 0.15, // lead thickness
  B      = 0.25, // lead width
  alpha  = 5,   // mold draft angle top
  beta   = 5,   // mold draft angle bottom
)
{
  D = n_pins/2 * p;
  
  translate( [0,0,A1+A2/2] ) {
    difference() {
      color( [0.2, 0.2, 0.2] )
        cube( size=[D, E1, A2], center=true );
      translate( [-D/2+0.8, -E1/2+1, A1/2+A2/2-0.1] ) // pin 1 marker
        cylinder( d=1, h=0.3, center=false, $fn=20 );
    }
   
    // etch-on the name
    translate( [0,0,A2/2-eps] ) 
      electronics_label( name, letter_size=1.0 );
  }
  
  imin = -n_pins/4;
  imax = (n_pins/4)-1;
  for( i=[imin:imax] ) {
    translate( [i*p+p/2, E/2-L/2, c/2] ) rotate( [-phi,0,0] ) 
      color( "silver" )
        cube( size=[B,L,c], center=true );
    translate( [i*p+p/2, -E/2+L/2, c/2] ) rotate( [phi,0,0] ) 
      color( "silver" )
        cube( size=[B,L,c], center=true );
    
    // height of inner part of the wires is NOT specified,
    // we assume A/2
    translate( [i*p+p/2, 0, A1+A2/2] ) 
      color( "silver" )
        cube( size=[B,E-2*L,c], center=true );
    
    // interpolating wire pieces
    translate( [i*p+p/2, -E/2+L, A1+A2/4] ) rotate( [75,0,0] ) 
      color( "silver" )
        cube( size=[B,A/2,c], center=true );
    translate( [i*p+p/2, +E/2-L, A1+A2/4] ) rotate( [-75,0,0] ) 
      color( "silver" )
        cube( size=[B,A/2,c], center=true );
    
  }
}



module pdip_package_demo() {
  dx = -20*2.54; dy = 6*2.54;
  translate( [1*dx,0*dy,0] ) pdip_package( n_pins=16, name="7483", wire_hull=true );
  translate( [1*dx,1*dy,0] ) pdip_package( n_pins=14, name="7400" );
  translate( [1*dx,2*dy,0] ) pdip_package( n_pins=8, name="555", 
                              inner_pin_angles=[0,15,30,45, 60, 75, 90,-15],
                              outer_pin_angles=[0,15,0,45, -15, 0, 0, 15] );
  translate( [1*dx,3*dy,0] ) pdip_package( n_pins=22, name="Hugo" );

  translate( [2*dx,0*dy,0] ) pdip_package( n_pins=24, E = 15.24, E1=13.84, name="2764" );
  translate( [2*dx,2*dy,0] ) pdip_package( n_pins=40, E = 15.24, E1=13.84, name="600mil" );
  translate( [2*dx,5*dy,0] ) pdip_package( n_pins=64, E = 19.30, E1=17.02, name="750mil", inner_pin_angles=[15], outer_pin_angles=[15] );
  
}



/**
 * naming convention and dimensions taken from Microchip packaging reference,
 * "00049w.pdf"
 */
module pdip_package( 
  n_pins=16, 
  name="7404", 
  D = 9.46, // overall body-length: ignored, calculated from n_pins
  E = 7.94, // shoulder-to-shoulder-width, use 15.24 for 24pins+
  E1 = 6.35, // molded package width, use 13.84 for 24pins+
  eB = 9.40, // overall row spacing: pin spacing at pin ends
  inner_pin_angles=[15,30,45,30],
  outer_pin_angles=[15,0,90,90],
  wire_hull = false, wire_hull_diameter = 1.0,
)
{
   pitch = 2.54;
   sx = n_pins/2 * 2.54;
   sy = 6.35;
   sz = 3.30;
   A  = 3.94;
   A2 = 3.30; // model-package-thickness
   A1 = 0.38; // base-to-seating-plane
   B  = 0.46; // thickness of thin part of the leads
   B1 = 1.46; // thickness of thick part of the leads
   // E  = 7.94; // shoulder-to-shoulder-width
   // D  = 9.46; // overall-length
   c  = 0.29; // lead thickness
   L  = 3.30; // length of the thin part of the lead
   alpha = 10; // mold draft angle top
   beta  = 10; // mold draft angle bottom
  
   fudge = 0.1;
  
   translate( [0,0,A/2] ) {
     difference() {
       color( [0.2, 0.2, 0.2, 1] ) 
         cube( size=[sx, E1, sz], center=true ); // main body
       
        
       translate( [-sx/2+1.27, -E1/2+1.5, sz/2-1] ) // pin 1 marker
         cylinder( d=1, h=1.5, center=false, $fn=20 );
     }
  
     // etch-on the name
     translate( [0,0,sz/2] ) 
       electronics_label( name, letter_size=1.5 );
   }    
  
   imin = -n_pins/4;
   imax = (n_pins/4)-1;
   for( i=[imin:imax] ) {
     translate( [i*2.54+1.27,0,A/2] ) 
       color( "silver" )
         cube( size=[B1,E,c], center=true );
   }

   for( i=[imin:imax] ) { // pins 1 .. n/2 ("lower row")
     index = (i - imin);
     inner_pin_angle = (index <= len(inner_pin_angles)-1) ? inner_pin_angles[index] : 10.0;
     outer_pin_angle = (index <= len(outer_pin_angles)-1) ? outer_pin_angles[index] : 10.0;

     translate( [i*2.54+1.27+B1/2,-E/2,A/2] )
       rotate( [inner_pin_angle,180,0] ) 
         color( "silver" )
           cube( size=[B1,c,A/2+fudge], center=false );

     translate( [i*2.54+1.27+B/2,
                 -E/2 - A/2*sin(inner_pin_angle),
                  A/2 - A/2*cos(inner_pin_angle) ] )
       rotate( [outer_pin_angle,180,0] ) 
         color( "silver" )
           cube( size=[B,c,L], center=false );

     if (wire_hull) {
       translate( [i*2.54+1.27,
                   -E/2 - A/2*sin(inner_pin_angle),
                    A/2 - A/2*cos(inner_pin_angle) ] )
         rotate( [outer_pin_angle,180,0] ) 
           color( "green" )
             cylinder( d=wire_hull_diameter, h=L, center=false, $fn=40 );
     }
   }
     

   for( i=[imin:imax] ) { // pins n .. n/2+1
     index = n_pins - (i - imin) - 1;
     inner_pin_angle = (index <= len(inner_pin_angles)-1) ? inner_pin_angles[index] : 10.0;
     outer_pin_angle = (index <= len(outer_pin_angles)-1) ? outer_pin_angles[index] : 10.0;

     translate( [i*2.54+1.27-B1/2,E/2,A/2] )
       rotate( [inner_pin_angle,180,180] ) 
         color( "silver" )
           cube( size=[B1,c,A/2+fudge], center=false );
       
     translate( [i*2.54+1.27-B/2,
                 E/2 + A/2*sin(inner_pin_angle),
                 A/2 - A/2*cos(inner_pin_angle) ] )
       rotate( [outer_pin_angle,180,180] ) 
         color( "silver" )
           cube( size=[B,c,L], center=false );
     
     if (wire_hull) {
       translate( [i*2.54+1.27,
                   E/2 + A/2*sin(inner_pin_angle),
                   A/2 - A/2*cos(inner_pin_angle) ] )
         rotate( [outer_pin_angle,180,180] ) 
           color( "red" )
             cylinder( d=wire_hull_diameter, h=L, center=false, $fn=40 );
       
     }
   }
}




module electronics_demo() {
  d = 2.54;
  translate( [0,-30,0] )       push_button_simple();
  translate( [-30,10*d,0] )    Atmel_ATtiny85_SOP();

  translate( [-10*d,-30,0] )   HE5B_M2_deadman_switch();

  translate( [10*d,0,0] )    arduino_mini();
  translate( [10*d,10*d,0] ) arduino_pro_mini( headers=true, bores=true );
  translate( [10*d,20*d,0] ) teensy_20( headers=false, bores=true );
  translate( [10*d,30*d,0] ) arduino_pro_micro( headers=true, bores=true );
  
  translate( [30.5*d,0,0] )  arduino_nano( headers=false, bores=true, hull=false );
  translate( [30*d,10*d,0] ) teensy_32( headers=true, bores=true );
  translate( [10*d,20*d,0] ) teensy_20( headers=false, bores=true );
  translate( [30*d,20*d,0] ) teensy_36( headers=false, bores=true );
  translate( [0*d,10*d,0] )  Atmel_ATtiny85_SOP();
  translate( [30.5*d,-10*d,0] ) arduino_nano33iot( headers=true, bores=true, hull=false );
  translate( [30.5*d,-20*d,0] ) arduino_nano33iot( headers=true, bores=true, hull=true );

  translate( [10*d,-10*d,0] ) bluetooth_hc05();
  translate( [10*d,-20*d,0] ) bluetooth_hc05_breakout();
}
 

 
/** one of these low-end dirt-cheap push-buttons.
    Object is aligned at z=0 and centered in x and y.
    Pins are offset by 2.54mm in x and 1.4*2.54 in y.
 */
module push_button_simple() 
{
   w = 6.04;
   l = 6.04;
   h = 3.20;
   d_button = 3.30;
   h_button = 5.00 - 3.20;
   stroke = 0.2;
   l_wire = 4.50;
   
   // main body
   color( [0.5,0.5,0.5] ) 
     translate( [0,0,h/2] ) cube( size=[w,l,h], center=true );
   // actual button
   color( [0,0,0] ) 
     translate( [0,0,h-eps] ) cylinder( d=d_button, h=h_button, $fn=15, center = false );
   // four wires, 3x4 match to 2.54 hole breadboard ...
   silver() 
   for( dx=[-2.54, 2.54] ) {
     for( dy=[-1.4*2.54, +1.4*2.54] ) {
       translate( [dx,dy,h/2 - l_wire] )
         cylinder( d=1.2, h=l_wire, $fn=5, center=false );
    }
  }
}


// ################################################################

/**
 * mechanical drawing: page 7 
 * https://datasheets.raspberrypi.com/picow/pico-w-datasheet.pdf
 */
module raspberry_pico( wifi=false, hull=false, bores=true, 
    headers = [2.0, 5.0], // [top-length, bottom-length]
    screws  = [6.0, 3.0, 2.0, 3.0], // [top,top-head,bottom,bottom-head length]
)
{
  w = 21.0; //  9*2.54
  l = 51.5; // 20*2.54
  h = 1.0;
    
  difference() {
    // main PCB
    teensy_green()
    translate( [0,0,h/2] ) 
      cube( [l,w,h], center=true );
      
    if (bores) {
      // mounting screw holes near usb end
      for( dy=[-5.7, +5.7] )
        translate( [-l/2+2.0, dy, -eps] ) 
          cylinder( d=2.2,h=h+2*eps, $fn=30, center=false );

      // mounting screw holes near wifi end
      for( dy=[-5.7, +5.7] )
        translate( [l/2-2.0, dy, -eps] ) 
          cylinder( d=2.2,h=h+2*eps, $fn=30, center=false );
      
      for( ix=[-10:1:9] ) {
        // outer pins
        translate( [(ix+0.5)*2.54, 3.5*2.54,-eps] )
          cylinder( d=1.2,h=h+2*eps,$fn=17,center=false );
        
        translate( [(ix+0.5)*2.54,-3.5*2.54,-eps] )
          cylinder( d=1.2,h=h+2*eps,$fn=7,center=false );
          
        // castellated pins
        translate( [(ix+0.5)*2.54, 4.2*2.54,-eps] )
          cylinder( d=1.2,h=h+2*eps,$fn=17,center=false );
        translate( [(ix+0.5)*2.54,-4.2*2.54,-eps] )
          cylinder( d=1.2,h=h+2*eps,$fn=17,center=false );
      }
      
      // extra pins
      for( iy=[0:1:2] ) {
        translate( [2.5*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=h+2*eps,$fn=17,center=false );
      }
    }
  }
  
  if (len(headers) == 2) {
    top_length = headers[0];
    bot_length = headers[1]; 
    // outer pins
    for( ix=[-10:1:9] ) {
      color( "gold" )
      translate( [(ix+0.5)*2.54,3.5*2.54,-bot_length] )
        cylinder( d=1.0,h=top_length+bot_length,$fn=10,center=false );
      color( "gold" )
      translate( [(ix+0.5)*2.54,-3.5*2.54,-bot_length] )
        cylinder( d=1.0,h=top_length+bot_length,$fn=10,center=false );
      if (hull) color( "gold", 0.5 ) {
        translate( [(ix+0.5)*2.54,3.5*2.54,top_length/2] )
          cube( [3.1, 3.2, top_length+eps], center=true );
        translate( [(ix+0.5)*2.54,3.5*2.54,-bot_length/2] )
          cube( [3.1, 3.2, bot_length+eps], center=true );

        translate( [(ix+0.5)*2.54,-3.5*2.54,top_length/2] )
          cube( [3.1, 3.2, top_length+eps], center=true );
        translate( [(ix+0.5)*2.54,-3.5*2.54,-bot_length/2] )
          cube( [3.1, 3.2, bot_length+eps], center=true );
      }
    }
  }
  
  if (len(screws) == 4) {
    top_screw_length = screws[0];
    top_head_length  = screws[1]; // M2 DIN 912 inbus: head length < 2.0mm
    bot_screw_length = screws[2];
    bot_head_length  = screws[3];
    d_screw = 2.1; // M2 DIN 912 inbus: thread diameter 2.0mm
    d_head  = 4.0; // M2 DIN 912 inbus: head diameter < 3.8mm 
    
    color( "maroon", 0.3 )
    for( dy=[-5.7, +5.7] ) {
      translate( [l/2-2.0, dy, 0] ) 
        cylinder( d=d_screw,h=top_screw_length, $fn=20, center=false );
      translate( [l/2-2.0, dy, top_screw_length-eps] ) 
        cylinder( d=d_head,h=top_head_length, $fn=20, center=false );
      translate( [l/2-2.0, dy, -bot_screw_length+eps] ) 
        cylinder( d=d_screw,h=top_screw_length, $fn=20, center=false );
      translate( [l/2-2.0, dy, -bot_screw_length-bot_head_length] ) 
        cylinder( d=d_head,h=bot_head_length, $fn=20, center=false );
      translate( [-l/2+2.0, dy, 0] ) 
        cylinder( d=d_screw,h=top_screw_length, $fn=20, center=false );
      translate( [-l/2+2.0, dy, top_screw_length-eps] ) 
        cylinder( d=d_head,h=top_head_length, $fn=20, center=false );
      translate( [-l/2+2.0, dy, -bot_screw_length+eps] ) 
        cylinder( d=d_screw,h=top_screw_length, $fn=20, center=false );
      translate( [-l/2+2.0, dy, -bot_screw_length-bot_head_length] ) 
        cylinder( d=d_head,h=bot_head_length, $fn=20, center=false );
    }
  } // mounting screws
  
  // RP2040 processor 7x7x1
  color( [0,0,0] ) 
    translate( [-1*2.54, 0, h+0.5] ) 
      cube( size=[7,7,1], center=true );
  
  // Wifi thingy 10x12x1.8
  silver()
    translate( [5*2.54, 0, h+0.9] )
      cube( size=[10,12,1.8], center=true );
  
  // mini-USB connector
  silver()
    translate( [-9.0*2.54,0, h+1.5] )
      cube( size=[8,8,3], center=true );
  
  // label
  translate( [-2*2.54, 5, h+0.5] ) 
    electronics_label( "Raspberry Pico (W)" );
    
  if (hull) {
   htop = 2.7;
   color( [1,0,0,0.4] ) 
   translate( [0,0,h+htop/2-eps] )
     cube( [l, 16, htop], center=true );
  }
}

// ################################################################





module arduino_nano( headers=false, headers_pin_length=6, bores=true, 
  hull=true, hull_headers_pin_length=4 ) {
  w = 17 * 2.54;
  l = 7 * 2.54;
  h = 1.0;
  difference() {
    // main PCB
    arduino_blue() translate( [0,0,h/2] )
      cube( size=[w,l,h], center=true );
    if (bores && !hull) {
      // outer pins
      for( ix=[-7:1:7] ) {
        translate( [ix*2.54,3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [ix*2.54,-3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // SPI/programming pins
      for( iy=[-1:1:1] ) {
        translate( [8*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [7*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      } 

      // outer mounting bores
      for( ix=[-8,8] ) for( iy=[-3,3] )
        translate( [ix*2.54,iy*2.54,-eps] )
          cylinder( d=1.5,h=1+2*eps,$fn=7,center=false );
    } // if bores
  }

  // convex-hull including pin headers; main use is difference()
  // inside another model to cut out enough space for the Nano33IOT
  if (hull) {
    translate( [0,3.0*2.54,-hull_headers_pin_length/2] ) 
      cube( size=[w,1*2.54,hull_headers_pin_length], center=true );
    translate( [0,-3.0*2.54,-hull_headers_pin_length/2] ) 
      cube( size=[w,1*2.54,hull_headers_pin_length], center=true );
    translate( [0,0,2+eps] )
      cube( size=[w+eps,l+eps,4], center=true ); // top components
    translate( [0,0,-0.8+eps] )
      cube( size=[w,4*2.54,1.6], center=true ); // bottom components
  }

  if (headers) {
    // outer pins
    silver()
    for( ix=[-7:1:7] ) {
      translate( [ix*2.54,3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
      translate( [ix*2.54,-3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
    }
  }
  
  // Atmega328
  color( [0,0,0] ) 
    translate( [-2.5*2.54, 0, h+0.5] ) 
      rotate( [0,0,45] )
        cube( size=[7,7,1], center=true );
  // mini-USB connector
  silver()
    translate( [-8*2.54,0, h+1.5] )
      cube( size=[8,8,3], center=true );
  // label
  translate( [3*2.54, 0, h+0.5] ) 
    electronics_label( "Arduino nano");
} // arduino_nano



module arduino_nano33iot( 
  headers=false, headers_pin_length=6, 
  hull=false, hull_headers_pin_length=4,
  bores=true 
) {
  // w = 17 * 2.54;  // convex-hull including pin headers; main use is difference()
  w = 45; // 17 holes at 2.54 spacing plus a little bit extra
  // inside another model to cut out enough space for the Nano33IOT
  if (hull) {
    translate( [0,3.0*2.54,-hull_headers_pin_length/2] ) 
      cube( size=[w,1*2.54,hull_headers_pin_length], center=true );
    translate( [0,-3.0*2.54,-hull_headers_pin_length/2] ) 
      cube( size=[w,1*2.54,hull_headers_pin_length], center=true );
    translate( [0,0,2+eps] )
      cube( size=[w+eps,l+eps,4], center=true );
  }

  l = 7 * 2.54;
  h = 1.0;

  // convex-hull including pin headers; mahull_headers_pin_lengthin use is difference()
  // inside another model to cut out enough space for the Nano33IOT
if (hull) {
    translate( [0,3.0*2.54,-hull_headers_pin_length/2+2*eps] ) 
      cube( size=[w,1*2.54,hull_headers_pin_length], center=true );
    translate( [0,-3.0*2.54,-hull_headers_pin_length/2+2*eps] ) 
      cube( size=[w,1*2.54,hull_headers_pin_length], center=true );
    translate( [0,0,2+eps] )
      cube( size=[w+eps,l+eps,4], center=true );
}
else {

  difference() {
    // main PCB
    arduino_blue() translate( [0,0,h/2] )
      cube( size=[w,l,h], center=true );
    if (bores) {
      // outer pins and castellated pins
      for( ix=[-7:1:7] ) {
        translate( [ix*2.54,3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [ix*2.54,3.5*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [ix*2.54,-3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [ix*2.54,-3.5*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }

      // note: no SPI/programming pins on nano33IOT (unlike old nano)

      // outer mounting bores
      for( ix=[-8,8] ) for( iy=[-3,3] )
        translate( [ix*2.54,iy*2.54,-eps] )
          cylinder( d=1.5,h=1+2*eps,$fn=7,center=false );
    } // if bores
  }
  // pin headers, if enabled
  if (headers) {
    // outer pins
    silver()
    for( ix=[-7:1:7] ) {
      translate( [ix*2.54,3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
      translate( [ix*2.54,-3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
    }
  }

  // SAMD (ARM Cortex M0)
  black()
    translate( [-0.5*2.54, 0.5*2.54, h+0.5] ) 
      cube( size=[7,7,1], center=true );
  // NINA-WT02 (esp32 wifi)
  silver()
    translate( [5.5*2.54,0, h+0.5] )
      cube( size=[12,10,1], center=true );
  // mini-USB connector
  silver()
    translate( [-8*2.54,0, h+1.5] )
      cube( size=[8,8,3], center=true );
  // label
  translate( [-2*2.54, -1.6*2.54, h+0.5] ) 
    electronics_label( "Nano33IOT");
} // else hull
} // arduino_nano33iot




/** original Arduino mini 05 */
module arduino_mini( headers=false, headers_pin_length=6, bores=true ) {
  w = 12 * 2.54;
  l = 7 * 2.54;
  h = 1.0;
  difference() {
    // main PCB
    arduino_blue() translate( [0,0,h/2] )
      cube( size=[w,l,h], center=true );
    if (bores) {
      // outer pins
      for( ix=[-6:1:5] ) {
        translate( [(ix+0.5)*2.54,3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [(ix+0.5)*2.54,-3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // comm/programming pins
      for( iy=[-2:1:2] ) {
        translate( [-5.5*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // analog/SPI pins 
      for( iy=[-2,-1,1,2] )
        translate( [5.5*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      for( iy=[-2,-1] )
        translate( [4.5*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
    } // if bores
  }
  if (headers) {
    // outer pins only
    silver()
    for( ix=[-6:1:5] ) {
      translate( [(ix+0.5)*2.54,3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
      translate( [(ix+0.5)*2.54,-3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
    }
  }

  // Atmega328
  color( [0,0,0] ) 
    translate( [0.5*2.54, 0, h+0.5] ) 
      cube( size=[7,7,1], center=true );
  // labels
  translate( [-3*2.54, 0, h+0.5] ) 
    electronics_label( "Arduino");
  translate( [3.8*2.54, 0, h+0.5] ) 
    electronics_label( "Mini 05");
} // arduino_mini



/** sparkfun pro mini (3.3V / 5V).
 * note: some China clones have slightly different pins,
 * especially for the SPI and extra analog pins.
 */
module arduino_pro_mini( headers=false, headers_pin_length=6, bores=true ) {
  w = 13 * 2.54;
  l = 7 * 2.54;
  h = 1.0;
  difference() {
    // main PCB
    arduino_blue() translate( [0,0,h/2] )
      cube( size=[w,l,h], center=true );
    if (bores) {
      // outer pins
      for( ix=[-5:1:6] ) {
        translate( [(ix)*2.54,3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [(ix)*2.54,-3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // comm/programming pins
      for( iy=[-3:1:2] ) {
        translate( [-6*2.54,(iy+0.5)*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // analog/SPI pins 
      for( ix=[-2,-1,1,2] )
        translate( [(ix+0.5)*2.54,2*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
    } // if bores
  }
  if (headers) {
    // outer pins only
    silver()
    for( ix=[-5:1:6] ) {
      translate( [ix*2.54,3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
      translate( [ix*2.54,-3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
    }
  }
  // Atmega328
  color( [0,0,0] ) 
    translate( [0.5*2.54, 0, h+0.5] ) 
      rotate( [0,0,45] ) 
        cube( size=[7,7,1], center=true );
  // labels
  translate( [-3.3*2.54, 0, h+0.5] ) 
    electronics_label( "Sparkfun");
  translate( [4*2.54, 0, h+0.5] ) 
    electronics_label( "Pro Mini");
} // arduino_pro_mini





module teensy_20( headers=true, headers_pin_length=6, bores=true ) {
  w = 12 * 2.54;
  l = 7 * 2.54;
  h = 1.0;
  difference() {
    // main PCB
    teensy_green() translate( [0,0,h/2] )
      cube( size=[w,l,h], center=true );
    if (bores) {
      // outer pins
      for( ix=[-6:1:5] ) {
        translate( [(ix+0.5)*2.54,3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [(ix+0.5)*2.54,-3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // extra pins
      for( iy=[-3:1:3] ) {
        translate( [5.5*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
    }
  }
  if (headers) {
    // outer pins
    silver()
    for( ix=[-6:1:5] ) {
      translate( [(ix+0.5)*2.54,3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
      translate( [(ix+0.5)*2.54,-3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
    }
  }
  // Atmega32U4
  color( [0,0,0] ) 
    translate( [1*2.54, 0, h+0.5] ) 
      cube( size=[8,8,1], center=true );
  // mini-USB connector
  silver()
    translate( [-4.6*2.54,0, h+1.5] )
      cube( size=[8,8,3], center=true );
  // label
  translate( [1*2.54, 5, h+0.5] ) 
    electronics_label( "Teensy 2.0" );
} // teensy_20


module teensy_32( bores=true, headers=false, headers_pin_length=6 ) {
  w = 14 * 2.54;
  l = 7 * 2.54;
  h = 1.0;
  difference() {
    // main PCB
    teensy_green() translate( [0,0,h/2] )
      cube( size=[w,l,h], center=true );
    if (bores) {
      // outer pins
      for( ix=[-7:1:6] ) {
        translate( [(ix+0.5)*2.54,3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [(ix+0.5)*2.54,-3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // right side pins
      for( iy=[-3:1:3] ) {
        translate( [6.5*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // extra pins
      for( ix=[-6,-4,-3,-2] ) {
        translate( [(ix+0.5)*2.54,2*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // note: bottom-side solder pins not modeled
    } // if bores
  }
  if (headers) {
    // outer pins
    silver()
    for( ix=[-7:1:6] ) {
      translate( [(ix+0.5)*2.54,3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
      translate( [(ix+0.5)*2.54,-3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
    }
  }
  // Arm Cortex-M4
  color( [0,0,0] ) 
    translate( [2*2.54, 0, h+0.5] ) 
      cube( size=[10,10,1], center=true );
  // mini-USB connector
  silver()
    translate( [-6*2.54,0, h+1.5] )
      cube( size=[8,8,3], center=true );
  // label
  translate( [-2*2.54, 0, h+0.5] ) 
    electronics_label( "Teensy 3.2" );
} // teensy_32


module teensy_36( headers=false, headers_pin_length=6, bores=true ) {
  w = 24 * 2.54;
  l = 7 * 2.54;
  h = 1.0;
  difference() {
    // main PCB
    teensy_green() translate( [0,0,h/2] )
      cube( size=[w,l,h], center=true );
    if (bores) {
      // outer pins
      for( ix=[-12:1:11] ) {
        translate( [(ix+0.5)*2.54,3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [(ix+0.5)*2.54,-3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // right side pins
      for( iy=[-3:1:3] ) {
        translate( [6.5*2.54,iy*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // extra pins
      for( ix=[-11,-9,-8,-7] ) {
        translate( [(ix+0.5)*2.54,2*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // USB host port bores
      for( ix=[-9,-8,-7,-6,-5] ) {
        translate( [(ix)*2.54,-1.9*2.54,-eps] )
          cylinder( d=1.0,h=1+2*eps,$fn=7,center=false );
      }
    } // if bores
    // note: bottom-side solder pins not modeled
  }
  // note: headers only for the "main" pins
  if (headers) {
    // outer pins
    silver()
    for( ix=[-12:1:11] ) {
      translate( [(ix+0.5)*2.54,3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
      translate( [(ix+0.5)*2.54,-3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
    }
  }

  // Arm Cortex-M4
  color( [0,0,0] ) 
    translate( [1*2.54, 0, h+0.5] ) 
      cube( size=[12,12,1], center=true );
  // mini-USB connector
  silver()
    translate( [-11*2.54,0, h+1.5] )
      cube( size=[8,8,3], center=true );
  // micro-SD card
  silver()
    translate( [9.5*2.54,0, h+0.5] )
      cube( size=[11,11,1], center=true );
  // label
  translate( [-5*2.54, 0, h+0.5] ) 
    electronics_label( "Teensy 3.6" );
} // teensy_36



/**
 * square PSOP plastic small outline package for ATtiny85.
 * note: dimensions are different from soic package!
 */
module Atmel_ATtiny85_SOP() 
{
  body_width  = 5.25; // aka D,  min 5.13 max 5.35 no nominal given
  body_length = 5.30; // aka E1, min 5.18 max 5.40 no nominal given
  body_height = 1.7;  // aka A,  min 1.7 max 2.16 no nominal given 
  wire_length = (8.0 - 5.3)/2;  // (E-E1)/2
  wire_width  = 0.40;  // aka b, min 0.35, max 0.48 no nominal given
  wire_height = 0.25;  // aka C, min 0.15 max 0.35 no nominal given

  // main IC body 
  difference() {
    // main body
    color( [0,0,0] )
      translate( [0,0,body_height/2] )
        cube( size=[body_width, body_length, body_height], center=true );
    // pin 1 marker
    translate( [body_width/3,body_length/3,body_height] )
      cylinder( d=1, h=1, center=true, $fn=10 );
  }
  // wires
  for( i=[0:1:3] ) {
    x = (i-1.5) * 1.27;
    translate( [x, body_length/2+wire_length/2, 0.15] )
      color( [1,1,1] )
        cube( [wire_width, wire_length, wire_height], center=true );
     
    translate( [x, -body_length/2-wire_length/2, 0.15] )
      color( [1,1,1] )
        cube( [wire_width, wire_length, wire_height], center=true );
  }
  // label
  translate( [0, 0, body_height-eps] ) rotate( [0,0,180] ) 
    electronics_label( "Tiny85", letter_size=1.0 );
}


module arduino_pro_micro( headers=true, headers_pin_length=6, bores=true ) {
  w = 13 * 2.54;
  l = 7 * 2.54;
  h = 1.0;
  difference() {
    // main PCB
    teensy_green() translate( [0,0,h/2] )
      cube( size=[w,l,h], center=true );
    if (bores) {
      // outer pins
      for( ix=[-6:1:5] ) {
        translate( [(ix+1)*2.54,3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
        translate( [(ix+1)*2.54,-3.0*2.54,-eps] )
          cylinder( d=1.2,h=1+2*eps,$fn=7,center=false );
      }
      // no extra pins on the pro micro
    }
  }
  if (headers) {
    // outer pins
    silver()
    for( ix=[-6:1:5] ) {
      translate( [(ix+1)*2.54,3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
      translate( [(ix+1)*2.54,-3.0*2.54,-2/3*headers_pin_length] )
        cylinder( d=1.0,h=headers_pin_length+2*eps,$fn=10,center=false );
    }
  }
  // Atmega32U4
  color( [0,0,0] ) 
    translate( [1.5*2.54, 0, h+0.5] ) 
      cube( size=[8,8,1], center=true );
  // micro-USB connector
  silver()
    translate( [-5.8*2.54,0, h+1.5] )
      cube( size=[5,,7.4,2.5], center=true );
  // label
  translate( [1*2.54, 5, h+0.5] ) 
    electronics_label( "Pro Micro (32u4)" );
} // teensy_20





module bluetooth_hc05() {
  w = 27.0;
  l = 12.7;
  h =  1.0;

  difference() {
    // main module body, lying and centered, so antenna is +x
    teensy_green()
      translate( [0, 0, h/2] )
        cube( size=[w, l, h], center=true );

    // castellated pins both sides
    for( i=[0:1:13] ) {
      x = -w/2 + 1.5 + 1.27/2 + i*1.27;
      translate( [x, l/2, -eps] )
        cylinder( d=1, h=h+2*eps, center=false, $fn=fn );
      translate( [x, -l/2, -eps] )
        cylinder( d=1, h=h+2*eps, center=false, $fn=fn );
    }

    // castellated pins bottom
    for( i=[-4:1:4] ) {
      y = i*1.27;
      translate( [-w/2, y, -eps] )
        cylinder( d=1, h=h+2*eps, center=false, $fn=fn );
    }
  }     

  // label
  translate( [-2, 0, h+1+eps] ) 
    electronics_label( "HC-05", letter_size=2.0 );
 
  // fake chips
  black() 
    translate( [-9,-1,h+0.5] )
      cube( size=[5,7,1], center=true );
  black() 
    translate( [-2,-1,h+0.5] )
      cube( size=[7,7,1], center=true );

  // fake antenna 
  wa = 5;
  copper() 
    translate( [w/2-wa/2-1,0,h] )
      cube( size=[ wa, l-2, 0.05], center=true );
}



// deadman switch (off-on-off), origin at mount-point.
//& https://www.apem-idec.eu/he5b-series-474.html
//
module HE5B_M2_deadman_switch()
{
  h1 = 16.0; // total cap heigth
  d1 = 19.5; // cap diameter
  b1 =  6.0; // cap "bevel" height, approximate
  w1 =  2.0; // cap "bevel" width, approximate

  d2 = 15.5; // diameter of the bottom part 
  h2 = 15.0; // "bottom" part of the switch

  d3 = 17.5; // diameter of the screw
  h3 =  5.0; // screw 

  color( "yellow" ) {
    translate( [0,0,h1-b1] )
      minkowski() {
        cylinder( d=d1-b1, h=b1, center=false, $fn=100 );
        sphere( d=b1, $fn=100 );
      }
    cylinder( d=d1, h=h1-b1, center=false, $fn=100 );
  }

  color( "black" )
    translate( [0,0,-h2] )
      cylinder( d=d2, h=h2, center=false, $fn=fn );
  color( "black" )
    translate( [0,0,-h3-2] )
      cylinder( d=d3, h=h3, center=false, $fn=fn );
 
  // pins
  color( "silver" )
  for( x=[-4.8, 0, 4.8] ) 
    for( y=[-3.0, +3.0] )
      translate( [x,y,-h2-4.0] )
        cube( size=[2.8,0.5,8.0], center=true );;
}



/**
 * 6-pin breakout board for the HC05 bluetooth module.
 * Size usually not specified, I found 15.2x35.7x5.6mm.
 * Pins seem to be 1.27 mm from left edge...
 */
module bluetooth_hc05_breakout( headers=false ) {
  w = 35.7;
  l = 15.2;
  h =  1.0;

  difference() {
    // breakout pcb body, lying and centered, antenna +x
    arduino_blue()
      translate( [0, 0, h/2] )
        cube( size=[w, l, h], center=true );

    // six pins, 2.54 raster, on left side
    for( i=[-3:1:2] ) {
      translate( [-w/2+1.27, i*2.54+1.27, -eps])
        cylinder( d=1, h=1+2*eps, center=false, $fn=fn );
    }
  }

  translate( [3,0,h] ) bluetooth_hc05();
}




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

