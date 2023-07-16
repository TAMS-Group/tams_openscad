/** load_cells.scad
 * 
 * basic geometric model of common load_cell / strain_gage sensors
 * and amplifier boards.
 *
 * (c) 2021 fnh, hendrich@informatik.uni-hamburg.de
 */



translate( [0,80,0] ) tiny_load_cell(); 
translate( [100,50,0] ) sparkfun_hx711_load_cell_amp();
translate( [100, 0, 0] ) 
generic_hx711_load_cell_amp();

translate( [0,-80,0] ) 
  tiny_load_cell( l=30.0, w=8, h=4, h2=5, 
                  bore_offsets = [-12,12],
                  bore_diameters=[3.0,3.0] );
                  
translate( [0,-140,0] ) 
  tiny_load_cell( l=40.0, w=8, h=4, h2=5, 
                  waistbelt=[18,15,8] );

translate( [0,  0,0] ) load_cell_TAL220();   
translate( [0,-25,0] ) load_cell_TAL220B();                  
translate( [0,-50,0] ) load_cell_TAL221();                  
translate( [0, 25,0] ) load_cell_komputer_10kg();   
translate( [0, 50,0] ) load_cell_komputer_5kg();   
   
   
/** 
 * load cell 10 kg from komputer.de
 * same size as sparkfun, but differen screw positions,
 * note both left/right side threads are M4 (despite the variable name)
 */                  
module load_cell_komputer_10kg(
  load_cell_color = [0.8, 0.8, 0.8],
  sensor_size = [ 24,12,1 ],
  sensor_color = [1,1,1],
  m4_screw_length = 0,
  m4_top_screw_head_length = 0,
  m4_bot_screw_head_length = 0,
  m5_screw_length = 0,
  m5_top_screw_head_length = 0,
  m5_bot_screw_head_length = 0,
)
{
  ll = 75.2; ww = 12.7; hh = 12.7; hhgage = 1;
  
  
  difference() {
    union() {
      // main body
      color( load_cell_color )
        cube( [ll, ww, hh], center=true );
      
      // strain gages
      color( sensor_color ) 
      for( dz=[-hh/2-sensor_size[2]/2, hh/2+sensor_size[2]/2] ) 
        translate( [0,0,dz] ) 
          cube( [sensor_size[0], sensor_size[1], sensor_size[2]], center=true );
      
      // cable routing on one side
      color( sensor_color ) 
        translate( [7+10,ww/2,0] )
          cube( [14,1,hh], center=true );
    }

    // cylindrical cutouts
    for( dx=[-4,4] ) 
      translate( [dx,0,0] ) rotate( [90,0,0] ) 
        cylinder( d=12.0, h=20+ww+1, center=true, $fn=50 );
   
    // 2xM4 screw threads left side
    for( dx=[-ll/2+6,-ll/2+16] )
      translate( [dx,0,0] ) 
        cylinder( d=4.0, h=hh+1, center=true, $fn=50 );

    // 2xM4 screw threads right side
    for( dx=[ll/2-6,ll/2-16] )
      translate( [dx,0,0] ) 
        cylinder( d=4.0, h=hh+1, center=true, $fn=50 );
  }
     
  // optionally, extrude screws for use in diff() operation
  if (m4_screw_length > 0.0) {
    // 2xM4 screw threads
    for( dx=[ll/2-6,ll/2-16] )
      translate( [dx,0,0] ) 
        cylinder( d=4.0, h=hh+2*m4_screw_length+0.5, center=true, $fn=50 );
  }
  if (m4_top_screw_head_length > 0.0) {
    // 2xM4 screw heads, 
    for( dx=[ll/2-6,ll/2-16] )
      translate( [dx,0,hh/2+m4_screw_length+m4_top_screw_head_length/2] ) 
        cylinder( d=7.1, h=m4_top_screw_head_length, center=true, $fn=50 );
  }
  if (m4_bot_screw_head_length > 0.0) {
    // 2xM4 screw heads, 
    for( dx=[ll/2-6,ll/2-16] )
      translate( [dx,0,-(hh/2+m4_screw_length+m4_bot_screw_head_length/2)] ) 
        cylinder( d=7.1, h=m4_bot_screw_head_length, center=true, $fn=50 );
  }
  
  if (m5_screw_length > 0.0) {
    // 2xM5 screw threads
    for( dx=[-ll/2+6,-ll/2+16] )
      translate( [dx,0,0] ) 
        cylinder( d=4.0, h=hh+2*m5_screw_length+0.5, center=true, $fn=50 );
  }
  if (m5_top_screw_head_length > 0.0) {
    // 2xM5 screw heads
    for( dx=[-ll/2+6,-ll/2+16] )
      translate( [dx,0,hh/2+m5_screw_length+m5_top_screw_head_length/2] ) 
        cylinder( d=7.1, h=m5_top_screw_head_length, center=true, $fn=50 );
  }
  if (m5_bot_screw_head_length > 0.0) {
    // 2xM5 screw heads, 
    for( dx=[-ll/2+6,-ll/2+16] )
      translate( [dx,0,-(hh/2+m5_screw_length+m5_bot_screw_head_length/2)] ) 
        cylinder( d=7.1, h=m5_bot_screw_head_length, center=true, $fn=50 );
  }
} // load_cell_komputer_10kg
   



/** 
 * load cell 5 kg from komputer.de and reichelt.de
 * same size as sparkfun, but different screw positions (!),
 * left/right side threads are M4 and M5 (!)
 * screw bores spacing is 5.1 | 15 | 40 | 15 | 5.1
 */                  
module load_cell_komputer_5kg(
  load_cell_color = [0.8, 0.3, 0.8],
  sensor_size = [ 24,12,1 ],
  sensor_color = [1,1,1],
  m4_screw_length = 0,
  m4_top_screw_head_length = 0, // >= 4.0
  m4_bot_screw_head_length = 0,
  m5_screw_length = 0,
  m5_top_screw_head_length = 0, // >= 5.1
  m5_bot_screw_head_length = 0,
)
{
  ll = 80.2; ww = 12.7; hh = 12.7; hhgage = 1;
    
  dxl = [-ll/2 + 5.1, -ll/2 + 15 + 5.1];
  
  difference() {
    union() {
      // main body
      color( load_cell_color )
        cube( [ll, ww, hh], center=true );
      
      // strain gages
      color( sensor_color ) 
      for( dz=[-hh/2-sensor_size[2]/2, hh/2+sensor_size[2]/2] ) 
        translate( [0,0,dz] ) 
          cube( [sensor_size[0], sensor_size[1], sensor_size[2]], center=true );
      
      // cable routing on one side
      color( sensor_color ) 
        translate( [7+10,ww/2,0] )
          cube( [14,1,hh], center=true );
    }

    // cylindrical sensor cutouts
    for( dx=[-4,4] ) 
      translate( [dx,0,0] ) rotate( [90,0,0] ) 
        cylinder( d=12.0, h=20+ww+1, center=true, $fn=50 );
   
    // 2xM5 screw threads left side
    for( dx=dxl )
      translate( [dx,0,0] ) 
        cylinder( d=5.0, h=hh+1, center=true, $fn=50 );

    // 2xM4 screw threads right side
    for( dx=-dxl )
      translate( [dx,0,0] ) 
        cylinder( d=4.0, h=hh+1, center=true, $fn=50 );
  }
     
  // optionally, extrude screws for use in diff() operation
  if (m4_screw_length > 0.0) {
    // 2xM4 screw threads
    for( dx=-dxl )
      translate( [dx,0,0] ) 
        cylinder( d=4.0, h=hh+2*m4_screw_length+0.5, center=true, $fn=50 );
  }
  if (m4_top_screw_head_length > 0.0) {
    // 2xM4 screw heads, 
    for( dx=-dxl )
      translate( [dx,0,hh/2+m4_screw_length+m4_top_screw_head_length/2] ) 
        cylinder( d=7.1, h=m4_top_screw_head_length, center=true, $fn=50 );
  }
  if (m4_bot_screw_head_length > 0.0) {
    // 2xM4 screw heads, 
    for( dx=-dxl )
      translate( [dx,0,-(hh/2+m4_screw_length+m4_bot_screw_head_length/2)] ) 
        cylinder( d=7.1, h=m4_bot_screw_head_length, center=true, $fn=50 );
  }
  
  if (m5_screw_length > 0.0) {
    // 2xM5 screw threads
    for( dx=dxl )
      translate( [dx,0,0] ) 
        cylinder( d=5.0, h=hh+2*m5_screw_length+0.5, center=true, $fn=50 );
  }
  if (m5_top_screw_head_length > 0.0) {
    // 2xM5 screw heads
    for( dx=dxl )
      translate( [dx,0,hh/2+m5_screw_length+m5_top_screw_head_length/2] ) 
        cylinder( d=8.6, h=m5_top_screw_head_length, center=true, $fn=50 );
  }
  if (m5_bot_screw_head_length > 0.0) {
    // 2xM5 screw heads, 
    for( dx=dxl )
      translate( [dx,0,-(hh/2+m5_screw_length+m5_bot_screw_head_length/2)] ) 
        cylinder( d=7.1, h=m5_bot_screw_head_length, center=true, $fn=50 );
  }
} // load_cell_komputer_10kg

   

/** 
 * sparkfun load cell 10 kg
 * https://www.sparkfun.com/products/13329
 * www.htc-sensor.com miniature load cell TAL 220 3..200kg
 */                  
module load_cell_TAL220(
  load_cell_color = [0.8, 0.8, 0.8],
  sensor_size = [ 24,12,1 ],
  sensor_color = [1,1,1],
  m4_screw_length = 0,
  m4_top_screw_head_length = 0,
  m4_bot_screw_head_length = 0,
  m5_screw_length = 0,
  m5_top_screw_head_length = 0,
  m5_bot_screw_head_length = 0,
)
{
  ll = 80; ww = 12.7; hh = 12.7; hhgage = 1;
  
  
  difference() {
    union() {
      // main body
      color( load_cell_color )
        cube( [ll, ww, hh], center=true );
      
      // strain gages
      color( sensor_color ) 
      for( dz=[-hh/2-sensor_size[2]/2, hh/2+sensor_size[2]/2] ) 
        translate( [0,0,dz] ) 
          cube( [sensor_size[0], sensor_size[1], sensor_size[2]], center=true );
      
      // cable routing on one side
      color( sensor_color ) 
        translate( [7+10,ww/2,0] )
          cube( [14,1,hh], center=true );
    }

    // cylindrical cutouts
    for( dx=[-4,4] ) 
      translate( [dx,0,0] ) rotate( [90,0,0] ) 
        cylinder( d=12.0, h=20+ww+1, center=true, $fn=50 );
   
    // 2xM5 screw threads
    for( dx=[-ll/2+5,-ll/2+15] )
      translate( [dx,0,0] ) 
        cylinder( d=5.0, h=hh+1, center=true, $fn=50 );

    // 2xM4 screw threads
    for( dx=[ll/2-5,ll/2-15] )
      translate( [dx,0,0] ) 
        cylinder( d=4.0, h=hh+1, center=true, $fn=50 );
  }
     
  // optionally, extrude screws for use in diff() operation
  if (m4_screw_length > 0.0) {
    // 2xM4 screw threads
    for( dx=[ll/2-5,ll/2-15] )
      translate( [dx,0,0] ) 
        cylinder( d=4.0, h=hh+2*m4_screw_length+0.5, center=true, $fn=50 );
  }
  if (m4_top_screw_head_length > 0.0) {
    // 2xM4 screw heads, 
    for( dx=[ll/2-5,ll/2-15] )
      translate( [dx,0,hh/2+m4_screw_length+m4_top_screw_head_length/2] ) 
        cylinder( d=7.1, h=m4_top_screw_head_length, center=true, $fn=50 );
  }
  if (m4_bot_screw_head_length > 0.0) {
    // 2xM4 screw heads, 
    for( dx=[ll/2-5,ll/2-15] )
      translate( [dx,0,-(hh/2+m4_screw_length+m4_bot_screw_head_length/2)] ) 
        cylinder( d=7.1, h=m4_bot_screw_head_length, center=true, $fn=50 );
  }
  
  if (m5_screw_length > 0.0) {
    // 2xM5 screw threads
    for( dx=[-ll/2+5,-ll/2+15] )
      translate( [dx,0,0] ) 
        cylinder( d=5.0, h=hh+2*m5_screw_length+0.5, center=true, $fn=50 );
  }
  if (m5_top_screw_head_length > 0.0) {
    // 2xM5 screw heads
    for( dx=[-ll/2+5,-ll/2+15] )
      translate( [dx,0,hh/2+m5_screw_length+m5_top_screw_head_length/2] ) 
        cylinder( d=8.6, h=m5_top_screw_head_length, center=true, $fn=50 );
  }
  if (m5_bot_screw_head_length > 0.0) {
    // 2xM5 screw heads, 
    for( dx=[-ll/2+5,-ll/2+15] )
      translate( [dx,0,-(hh/2+m5_screw_length+m5_bot_screw_head_length/2)] ) 
        cylinder( d=8.6, h=m5_bot_screw_head_length, center=true, $fn=50 );
  }

} // load_cell_TAL220


   
                  
/** 
 * sparkfun load cell
 * https://www.sparkfun.com/products/14727
 * www.htc-sensor.com miniature load cell TAL 220B 2..50kg
 */                  
module load_cell_TAL220B(
  load_cell_color = [0.8, 0.8, 0.8],
  sensor_size = [ 24,12,1 ],
  sensor_color = [1,1,1],
)
{
  ll = 55; ww = 12.7; hh = 12.7; hhgage = 1;
  lb = 40; bbb = 3.0; dbb = 3.2; bby = 6.0; 
  li = 33; di = 20.0;
  
  
  difference() {
    union() {
      // main body
      color( load_cell_color )
        cube( [ll, ww, hh], center=true );
      
      // strain gages
      color( sensor_color ) 
      for( dz=[-hh/2-sensor_size[2]/2, hh/2+sensor_size[2]/2] ) 
        translate( [0,0,dz] ) 
          cube( [sensor_size[0], sensor_size[1], sensor_size[2]], center=true );
      
      // cable routing on one side
      translate( [ll/2-7-2,ww/2,0] )
        cube( [14+4,1,hh], center=true );
      
    }

    // cylindrical cutouts
    for( dx=[-4,4] ) 
      translate( [dx,0,0] ) rotate( [90,0,0] ) 
        cylinder( d=12.0, h=20+ww+1, center=true, $fn=50 );
   
    // M5 screw threads
    for( dx=[-lb/2,lb/2] )
      translate( [dx,0,0] ) 
        cylinder( d=5.0, h=hh+1, center=true, $fn=50 );
    
  }
} // load_cell_TAL221



/** 
 * sparkfun load cell
 * https://www.sparkfun.com/products/14729
 * www.htc-sensor.com miniature load cell TAL 220B 2..50kg
 */                  
module load_cell_TAL220B(
  load_cell_color = [0.8, 0.8, 0.8],
  sensor_size = [ 24,12,1 ],
  sensor_color = [1,1,1],
)
{
  ll = 55; ww = 12.7; hh = 12.7; hhgage = 1;
  lb = 40; bbb = 3.0; dbb = 3.2; bby = 6.0; 
  li = 33; di = 20.0;
  
  
  difference() {
    union() {
      // main body
      color( load_cell_color )
        cube( [ll, ww, hh], center=true );
      
      // strain gages
      color( sensor_color ) 
      for( dz=[-hh/2-sensor_size[2]/2, hh/2+sensor_size[2]/2] ) 
        translate( [0,0,dz] ) 
          cube( [sensor_size[0], sensor_size[1], sensor_size[2]], center=true );
      
      // cable routing on one side
      translate( [ll/2-7-2,ww/2,0] )
        cube( [14+4,1,hh], center=true );
      
    }

    // cylindrical cutouts
    for( dx=[-4,4] ) 
      translate( [dx,0,0] ) rotate( [90,0,0] ) 
        cylinder( d=12.0, h=20+ww+1, center=true, $fn=50 );
   
    // M5 screw threads
    for( dx=[-lb/2,lb/2] )
      translate( [dx,0,0] ) 
        cylinder( d=5.0, h=hh+1, center=true, $fn=50 );
    
  }
} // load_cell_TAL220B


   
                  
/** 
 * sparkfun 100g load cell
 * https://www.sparkfun.com/products/14727
 * www.htc-sensor.com miniature load cell TAL 221 
 */                  
module load_cell_TAL221(
  load_cell_color = [0.8, 0.8, 0.8],
  sensor_size = [ 30,6,1 ],
  sensor_color = [1,1,1],
)
{
  ll = 47; ww = 12; hh = 6; hhgage = 1;
  lb = 40; bbb = 3.0; dbb = 3.2; bby = 6.0; 
  li = 33; di = 20.0;
  
  
  difference() {
    union() {
      // main body
      color( load_cell_color )
        cube( [ll, ww, hh], center=true );
      
      // strain gages
      color( sensor_color ) 
      for( dz=[-hh/2-sensor_size[2]/2, hh/2+sensor_size[2]/2] ) 
        translate( [0,0,dz] ) 
          cube( [sensor_size[0], sensor_size[1], sensor_size[2]], center=true );
    }
    
    // side cutouts
    for( dy=[-ww/2, ww/2] )
      hull() {
        translate( [-33/2+2,dy,0] ) 
          cylinder( d=4, h=hh+1, center=true, $fn=15 );
        translate( [+33/2-2,dy,0] ) 
          cylinder( d=4, h=hh+1, center=true, $fn=15 );
    }

    // cylindrical cutouts
    for( dx=[-10,10] ) 
      translate( [dx,0,0] ) rotate( [90,0,0] ) 
        cylinder( d=5.3, h=20+ww+1, center=true, $fn=50 );
   
    // center cutout
    cube( [20,ww+1,3], center=true );
    
    // screw threads (left)
    for( dy=[-3,+3] )
      translate( [-lb/2,dy,0] ) 
        cylinder( d=3.0, h=hh+1, center=true, $fn=50 );
    
    // screw through bores (right)
    for( dy=[-3,+3] )
      translate( [lb/2,dy,0] ) 
        cylinder( d=3.2, h=hh+1, center=true, $fn=50 );
  }
} // load_cell_TAL221


 
 
/**
 * thin bar load cell of given dimensions. 
 * Model origin is at the center of the bar, orientation along x,
 * sensor at +z.
 */
module tiny_load_cell(
  l = 40.0,
  h =  3.0,
  h2 = 4.0,
  w =  8.0,
  bore_offsets = [-13.5, 13.5],
  bore_diameters = [4.1, 4.1],
  load_cell_color = [0.8, 0.8, 0.8],
  sensor_size = [ 20,8,1 ],
  sensor_color = [1,1,1],
  extrude_screws_length = 10,
  extrude_screws_head_length = 20,
  extrude_screws_head_diameter = 6,
  cable_color  = [1,0,0],
  waistbelt = [],
)
{
  difference() {
    union() { 
      // main load cell metal bar
      color( load_cell_color )
        cube( [l,w,h], center=true );
      // strain gage sensor blob
      color( sensor_color )
        translate( [0,0,h/2 + sensor_size[2]/2] )
          cube( [sensor_size[0], sensor_size[1], sensor_size[2]], center=true );
      color( cable_color )
        translate( [-2.5, w/2+2/2, h2/2-h/2] ) 
          cube( [5,2,h2], center=true );
      
    }
    // screw bores
    for( i = [0:len(bore_offsets)-1] ) {
      dx = bore_offsets[i];
      translate( [dx, 0, 0] )
        cylinder( d=bore_diameters[i], h=h2, center=true, $fn=50 );
    }
  } // difference
  
  if (extrude_screws_length > 0) {
    for( i = [0:len(bore_offsets)-1] ) {
      dx = bore_offsets[i];
      translate( [dx, 0, 0] )
        cylinder( d=bore_diameters[i], h=extrude_screws_length, center=true, $fn=50 );
    }
  }
  if (extrude_screws_head_length > 0) {
    for( i = [0:len(bore_offsets)-1] ) {
      dx = bore_offsets[i];
      translate( [dx, 0, extrude_screws_length/2] )
        cylinder( d=extrude_screws_head_diameter, h=extrude_screws_head_length, center=false, $fn=50 );
      translate( [dx, 0, -extrude_screws_length/2-extrude_screws_head_length] )
        cylinder( d=extrude_screws_head_diameter, h=extrude_screws_head_length, center=false, $fn=50 );
    }
  }
  
  if (len(waistbelt) > 0) {
    color( "silver", 0.8 )
     cube( [waistbelt[0], waistbelt[1], waistbelt[2]], center=true ); 
  }
} // tiny_load_cell



module generic_hx711_load_cell_amp( headers=true, header_pin_length=8 )
{
  l = 33.5; w = 20.5; h = 1.5; xh = 2; zh = 2;
  difference() {
    union() {
      // main pcb
      color( "darkgreen" )
      translate( [0,0,h/2] )
        cube( [l,w,h], center=true );
      // hx 711 chip
      color( "black" )
        translate( [0,0,h+0.5] )  
          cube( [4.5, 10.0, 1.0], center=true );
        
      if (headers) {
        color( "black") 
          translate( [-l/2+3,0,h+zh/2] )
            cube( [2.54, 6*2.54, zh], center=true );
        color( "black") 
          translate( [l/2-4.5,0,h+zh/2] )
            cube( [2.54, 5*2.54, zh], center=true );
      }
    }
    
    // two M3 mounting bores d=3.15
    dd = 3.15;
    translate( [l/2-3.0-dd/2, w/2-1.0-dd/2, -0.1] )
      cylinder( d=dd, h=h+0.2, center=false, $fn=20 );
    translate( [l/2-3.0-dd/2, -w/2+1.0+dd/2, -0.1] )
      cylinder( d=dd, h=h+0.2, center=false, $fn=20 );

    for( i=[-1.5, -0.5, 0.5, 1.5 ] ) {
      dy = i * 2.54;
      translate( [l/2-4.5,dy,-0.2] ) 
        cylinder( d=1.0, h=h+zh+1, center=false, $fn=20 );
    }
    for( i=[-2.5, -1.5, -0.5, 0.5, 1.5, 2.5 ] ) {
      dy = i * 2.54;
      translate( [-l/2+3.0,dy,-0.2] ) 
        cylinder( d=1.0, h=h+zh+1, center=false, $fn=20 );
    }    
  } // difference
  
  if (header_pin_length > 0) {
    for( i=[-1.5, -0.5, 0.5, 1.5 ] ) {
      dy = i * 2.54;
      translate( [l/2-4.5,dy,-0.2] ) 
        cylinder( d=0.8, h=header_pin_length, center=false, $fn=20 );
    }    
    for( i=[-2.5, -1.5, -0.5, 0.5, 1.5, 2.5 ] ) {
      dy = i * 2.54;
      translate( [-l/2+3.0,dy,-0.2] ) 
        cylinder( d=0.8, h=header_pin_length, center=false, $fn=20 );
    }    
  }
}



module sparkfun_hx711_load_cell_amp( headers=true, header_pin_length=10 )
{
  l = 31.2; w = 23.4; h = 1.6; xh = l/2 - 2.54/2; zh = 5.05;
  difference() {
    union() {
      // main pcb
      color( "darkred" )
      translate( [0,0,h/2] )
        cube( [l,w,h], center=true );
      // hx 711 chip
      color( "black" )
        translate( [0,0,h+0.5] )  
          cube( [4.5, 10.0, 1.0], center=true );
      if (headers) {
        color( "black") 
          translate( [-xh,0,h+zh/2] )
            cube( [2.54, 5*2.54, zh], center=true );
        color( "black") 
          translate( [+xh,0,h+zh/2] )
            cube( [2.54, 5*2.54, zh], center=true );
      }
    }

    for( i=[-2,-1,0,1,2] ) {
      dy = i * 2.54;
      translate( [-xh,dy,-0.5] ) 
        cylinder( d=1.0, h=h+zh+1, center=false, $fn=20 );
      translate( [+xh,dy,-0.5] ) 
        cylinder( d=1.0, h=h+zh+1, center=false, $fn=20 );
    }    
  } // difference
  
  if (header_pin_length > 0) {
    for( i=[-2,-1,0,1,2] ) {
      dy = i * 2.54;
      translate( [-xh,dy,-0.2] ) 
        cylinder( d=0.8, h=header_pin_length, center=false, $fn=20 );
      translate( [+xh,dy,-0.2] ) 
        cylinder( d=0.8, h=header_pin_length, center=false, $fn=20 );
    }    
    
  }
} // sparkfun_hx711_load_cell_amp

