/** simplified screws and nuts, several DIN/ISO variants.
 *  Includes fdm_fudge (radial) option and extra thread/head
 *  length to create suitable bores/cavities in your designs.
 *
 * (C) 2020, fnh, hendrich@informatik.uni-hamburg.de
 */
 
screw_fn = 100;
screw_debug = 0;
screw_eps = 0.1; // use ~0.1 for FDM, smaller for better technologies

demo();




module demo() {
  echo( "simple screws demo v1..." );
  
  dx = [10,  20, 30, 40, 50, 65, 80, 100, 125];
  sx = [ 2, 2.5,  3,  4,  5,  6,  8, 10, 12 ];
  lx = [ 5,  10,  8, 10, 12, 20, 40, 45, 60 ];
  ex = [ 0,   1,  5,  0,  0, 20,  0,  0, 30 ];
  hull = [ 0, 0,  0,  1,  0,  0,  0,  1, 1 ];
  
  for( i=[0:len(dx)-1] ) { // DIN 7991 countersunk screws hex
    translate( [dx[i], 0, 0 ] )
      screw_DIN7991( d=sx[i], l=lx[i], fdm_fudge=0.2,
                             extra_head_length = ex[i],
                             extra_thread_length = ex[i],
                             hull = hull[i] ); 
  }
  
  for( i=[0:len(dx)-1] ) { // DIN 912
    translate( [dx[i], 50, 0 ] )
      screw_DIN912( d=sx[i], l=lx[i], fdm_fudge=0.2,
                             extra_head_length = ex[i],
                             extra_thread_length = ex[i],
                             hull = hull[i] ); 
  }

  for( i=[0:5] ) { // DIN 921 Flachkopf, großer Kopf
    translate( [dx[i], 100, 0 ] )
      screw_DIN921( d=sx[i], l=lx[i], fdm_fudge=0.2,
                             extra_head_length = ex[i],
                             extra_thread_length = ex[i],
                             hull = hull[i] ); 
  }

  for( i=[0:len(dx)-1] ) { // DIN 933 Sechskant mit Schlitz
    translate( [dx[i], 150, 0 ] )
      screw_DIN933( d=sx[i], l=lx[i], fdm_fudge=0.2,
                             extra_head_length = ex[i],
                             extra_thread_length = ex[i],
                             hull = hull[i] ); 
  }
  
  for( i=[0:len(dx)-1] ) { // DIN 934 Sechskantmutter
    translate( [dx[i], 200, 0 ] )
      nut_DIN934( d=sx[i], fdm_fudge=0.2,
                  extra_front_length = ex[i], 
                  extra_rear_length = ex[i], 
                  hull = hull[i] ); 
  }

  for( i=[0:len(dx)-1] ) { // DIN 936 "thin" Sechskantmutter
    translate( [dx[i], 250, 0 ] )
      nut_DIN936( d=sx[i], fdm_fudge=0.2,
                  extra_front_length = ex[i], 
                  extra_rear_length = ex[i],
                  hull = hull[i] ); 
  }

  for( i=[0:len(dx)-1] ) { // DIN 963 Schlitzschraube
    translate( [dx[i],450, 0 ] )
      screw_DIN963( d=sx[i], l=lx[i], fdm_fudge=0.2,
                       extra_head_length = ex[i],
                       extra_thread_length = ex[i],
                       hull = hull[i] ); 
  }

  for( i=[0:len(dx)-1] ) { // DIN 965 Ph/Pz/Torx Senkschraube
    translate( [dx[i], 350, 0 ] )
      screw_DIN965_PH( d=sx[i], l=lx[i], fdm_fudge=0.2,
                       extra_head_length = ex[i],
                       extra_thread_length = ex[i],
                       hull = hull[i] ); 
  }

  for( i=[0:len(dx)-1] ) { // DIN 965 Torx Senkschraube
    translate( [dx[i], 400, 0 ] )
      screw_DIN965_TX( d=sx[i], l=lx[i], fdm_fudge=0.2,
                       extra_head_length = ex[i],
                       extra_thread_length = ex[i],
                       hull = hull[i] ); 
  }
  
  for( i=[0:len(dx)-1] ) { // DIN 9021 "large" washer
    translate( [dx[i], 300, 0 ] )
      washer_DIN9021( d=sx[i], fdm_fudge=0.2,
                      extra_front_length = ex[i], 
                      extra_rear_length = ex[i],
                      hull = hull[i] ); 
  }

  for( i=[0:len(dx)-1] ) { // DIN 556 quadratic nut
    translate( [dx[i], 500, 0 ] )
      nut_DIN557( d=sx[i], fdm_fudge=0.1, hull=false );
  }

  #for( i=[0:len(dx)-1] ) { // DIN 562 quadratic nut thin
    translate( [dx[i], 550, 0 ] )
      nut_DIN562( d=sx[i], fdm_fudge=0.1, hull=false );
  }
  
} // end demo


module screw_DIN7991(
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  hull = false,
  thread_modeled = false,
)
{
  hex_screw_countersunk( d=d, l=l, fdm_fudge=fdm_fudge,
    extra_head_length = extra_head_length,
    extra_thread_length = extra_thread_length,
    hull = hull ); 
}


module hex_screw_countersunk( 
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  hull = false,
  thread_modeled = false,
)
{
  // [mx, dk, k, b, t, s, e] = DIN_7991_ISO_10642_table[2];
  for( i=[0:len(DIN_7991_ISO_10642_table)-1] ) {
    data = DIN_7991_ISO_10642_table[i];
    if (screw_debug) { echo( "DIN_7991 i ", i, "data: ", data ); }
    
    if (data[0] == d) {
      d1 = data[1] + fdm_fudge; d2 = data[0] + fdm_fudge; hh = data[2];
      color( "silver" ) {
        difference() {
          cylinder( d1=d1, d2=d2, h=hh, center=false, $fn=screw_fn );
          if (!hull) {
            translate( [0,0,-screw_eps] ) cylinder( d=data[6], h=data[4], center=false, $fn=6 );
          }  
        }
        translate( [0,0,hh-screw_eps] )
          cylinder( d=d2, h=l-hh+screw_eps, center=false, $fn=screw_fn );
      }
      // optional extra-head-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_head_length] )
          cylinder( d=d1, h=extra_head_length+screw_eps, center=false, $fn=screw_fn );
      // optional extra-thread
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,l-screw_eps] )
          cylinder( d=d2, h=extra_thread_length+screw_eps, center=false, $fn=screw_fn );
    } // if d 
  } // end for 
}

 


module hex_screw( 
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  thread_modeled = false,
  hull = false, 
)
{ 
  screw_DIN912( d, l, fdm_fudge, 
                extra_head_length=0.0, extra_thread_length=0.0,
                hull = hull );
}


module screw_DIN912( 
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  thread_modeled = false,
  hull = false, 
)
{
  // [mx, dk, k, b, t, s, e] = DIN_912_ISO_4762_table[...]
  for( i=[0:len(DIN_912_ISO_4762_table)-1] ) {
    data = DIN_912_ISO_4762_table[i];
    if (screw_debug) { echo( "DIN912 i ", i, "data: ", data ); }
    if (data[0] == d) {
      d1 = data[1] + fdm_fudge; d2 = data[0] + fdm_fudge; hh = data[2];
      color( "silver" ) {
        difference() {
          cylinder( d=d1, h=hh, center=false, $fn=screw_fn );
          if (!hull) {
            translate( [0,0,-screw_eps] ) cylinder( d=data[6], h=data[4], center=false, $fn=6 );
          }
        }
        translate( [0,0,hh-screw_eps] )
          cylinder( d=d2, h=l-hh+screw_eps, center=false, $fn=screw_fn );
      }
      // optional extra-head-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_head_length] )
          cylinder( d=d1, h=extra_head_length+screw_eps, center=false, $fn=screw_fn );
      // optional extra-thread
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,l-screw_eps] )
          cylinder( d=d2, h=extra_thread_length+screw_eps, center=false, $fn=screw_fn );
    } // if d 
  } // end for 
}

module screw_DIN912_M2x4 ( extra_head_length = 0.0 ) { screw_DIN912( d=2.0, l=4.0,  extra_head_length=extra_head_length ); }
module screw_DIN912_M2x6 ( extra_head_length = 0.0 ) { screw_DIN912( d=2.0, l=6.0,  extra_head_length=extra_head_length ); }
module screw_DIN912_M2x10( extra_head_length = 0.0 ) { screw_DIN912( d=2.0, l=10.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M2x12( extra_head_length = 0.0 ) { screw_DIN912( d=2.0, l=12.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M2x16( extra_head_length = 0.0 ) { screw_DIN912( d=2.0, l=16.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M2x20( extra_head_length = 0.0 ) { screw_DIN912( d=2.0, l=20.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M2x30( extra_head_length = 0.0 ) { screw_DIN912( d=2.0, l=30.0, extra_head_length=extra_head_length ); }

module screw_DIN912_M3x8 ( extra_head_length = 0.0 ) { screw_DIN912( d=3.0, l=8.0,  extra_head_length=extra_head_length ); }
module screw_DIN912_M3x10( extra_head_length = 0.0 ) { screw_DIN912( d=3.0, l=10.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M3x12( extra_head_length = 0.0 ) { screw_DIN912( d=3.0, l=12.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M3x16( extra_head_length = 0.0 ) { screw_DIN912( d=3.0, l=16.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M3x20( extra_head_length = 0.0 ) { screw_DIN912( d=3.0, l=20.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M3x30( extra_head_length = 0.0 ) { screw_DIN912( d=3.0, l=30.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M3x50( extra_head_length = 0.0 ) { screw_DIN912( d=3.0, l=50.0, extra_head_length=extra_head_length ); }

module screw_DIN912_M4x8 ( extra_head_length = 0.0 ) { screw_DIN912( d=4.0, l=8.0,  extra_head_length=extra_head_length ); }
module screw_DIN912_M4x10( extra_head_length = 0.0 ) { screw_DIN912( d=4.0, l=10.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M4x12( extra_head_length = 0.0 ) { screw_DIN912( d=4.0, l=12.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M4x16( extra_head_length = 0.0 ) { screw_DIN912( d=4.0, l=16.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M4x20( extra_head_length = 0.0 ) { screw_DIN912( d=4.0, l=20.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M4x30( extra_head_length = 0.0 ) { screw_DIN912( d=4.0, l=30.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M4x50( extra_head_length = 0.0 ) { screw_DIN912( d=4.0, l=50.0, extra_head_length=extra_head_length ); }

module screw_DIN912_M5x8 ( extra_head_length = 0.0 ) { screw_DIN912( d=5.0, l=8.0,  extra_head_length=extra_head_length ); }
module screw_DIN912_M5x10( extra_head_length = 0.0 ) { screw_DIN912( d=5.0, l=10.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M5x12( extra_head_length = 0.0 ) { screw_DIN912( d=5.0, l=12.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M5x16( extra_head_length = 0.0 ) { screw_DIN912( d=5.0, l=16.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M5x20( extra_head_length = 0.0 ) { screw_DIN912( d=5.0, l=20.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M5x35( extra_head_length = 0.0 ) { screw_DIN912( d=5.0, l=35.0, extra_head_length=extra_head_length ); }
module screw_DIN912_M5x50( extra_head_length = 0.0 ) { screw_DIN912( d=5.0, l=50.0, extra_head_length=extra_head_length ); }


/**
 * Flachkopfschrauben mit Schlitz, großer Kopf, DIN 921
 * https://www.schrauben-lexikon.de/norm/DIN_921.asp
 */
module screw_DIN921( 
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  thread_modeled = false,
  hull = false, 
)
{
  // [mx, dk, k, n, t] = DIN_921_table[]
  for( i=[0:len(DIN_921_table)-1] ) {
    data = DIN_921_table[i];
    if (screw_debug) { echo( "DIN_921: i ", i, "data: ", data ); }
    if (data[0] == d) {
      d1 = data[1] + fdm_fudge; d2 = data[0] + fdm_fudge; hh = data[2];
      n = data[3]; t = data[4];
      color( "silver" ) {
        difference() {
          cylinder( d=d1, h=hh, center=false, $fn=screw_fn );
          if (!hull) {
            cube( [n, d1+screw_eps, 2*t], center=true );
          }
        }
        translate( [0,0,hh-screw_eps] )
          cylinder( d=d2, h=l-hh+screw_eps, center=false, $fn=screw_fn );
      }
      // optional extra-head-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_head_length] )
          cylinder( d=d1, h=extra_head_length+screw_eps, center=false, $fn=screw_fn );
      // optional extra-thread
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,l-screw_eps] )
          cylinder( d=d2, h=extra_thread_length+screw_eps, center=false, $fn=screw_fn );
    } // if d 
  } // end for 
}


/**
 * Sechskantschrauben, Gewinde bis Kopf, mit Schlitz, DIN 933 SZ
 * https://www.schrauben-lexikon.de/norm/DIN_933SZ.asp
 */
module screw_DIN933( 
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  thread_modeled = false,
  hull = false, 
)
{
  // [mx, dk, k, n, t] = DIN_921_table[]
  for( i=[0:len(DIN_933_table)-1] ) {
    data = DIN_933_table[i];
    if (screw_debug) { echo( "DIN_933: i ", i, "data: ", data ); }
    if (data[0] == d) {
      d1 = data[1] / cos(180/6) + fdm_fudge; 
      d2 = data[0] + fdm_fudge; hh = data[2];
      n = data[3]; t = data[4];
      color( "silver" ) {
        difference() {
          cylinder( d=d1, h=hh, center=false, $fn=6 );
          if (!hull) {
            cube( [n, d1+screw_eps, 2*t], center=true );
          }
        }
        // cylinder( d=data[1]+0.1, h=hh/4, center=false, $fn=100 );
        
        translate( [0,0,hh-screw_eps] )
          cylinder( d=d2, h=l-hh+screw_eps, center=false, $fn=screw_fn );
      }
      // optional extra-head-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_head_length] )
          cylinder( d=d1, h=extra_head_length+screw_eps, center=false, $fn=screw_fn );
      // optional extra-thread
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,l-screw_eps] )
          cylinder( d=d2, h=extra_thread_length+screw_eps, center=false, $fn=screw_fn );
    } // if d 
  } // end for 
}


/**
 * Vierkantmutter DIN 557 (normal thickness)
 * d = thread diameter
 * s = side-length
 * e = edge-to-edge length
 * m = thickness
 * origin is at z=0.
 */
module nut_DIN557(
  d=4.0, fdm_fudge=0.2,
  hull = false,
)
{
  // [name, d, s, e, m] = DIN_557_table[]
  for( i=[0:len(DIN_557_table)-1] ) {
    data = DIN_557_table[i];
    if (screw_debug) { echo( "DIN_557: i ", i, "data: ", data ); }
    if (data[1] == d) {
      s = data[2];
      e = data[3];
      m = data[4];

      color( "silver" )
      difference() {
        translate( [0,0,m/2] )
          cube( [s,s,m], center=true );
        if (!hull) {
          translate( [0,0,-screw_eps] ) 
            cylinder( d=data[1] + fdm_fudge, h=data[4]+2*screw_eps, center=false, $fn=screw_fn );
        }
      } 
    }
  }
}


/**
 * Vierkantmutter DIN 562 (thin)
 * d = thread diameter
 * s = side-length
 * e = edge-to-edge length
 * m = thickness
 * origin is at z=0.
 */
module nut_DIN562(
  d=4.0, fdm_fudge=0.2,
  hull = false,
)
{
  // [name, d, s, e, m] = DIN_557_table[]
  for( i=[0:len(DIN_562_table)-1] ) {
    data = DIN_562_table[i];
    if (screw_debug) { echo( "DIN_562: i ", i, "data: ", data ); }
    if (data[1] == d) {
      s = data[2];
      e = data[3];
      m = data[4];

      color( "silver" )
      difference() {
        translate( [0,0,m/2] )
          cube( [s,s,m], center=true );
        if (!hull) {
          translate( [0,0,-screw_eps] ) 
            cylinder( d=data[1] + fdm_fudge, h=data[4]+2*screw_eps, center=false, $fn=screw_fn );
        }
      } 
    }
  }
}





module nut_DIN934(
  d=3.0, fdm_fudge=0.2, 
  extra_front_length = 0.0, extra_rear_length = 0.0,
  thread_modeled = false,
  hull = false, 
)
{
  // [mx, dk, k, n, t] = DIN_921_table[]
  for( i=[0:len(DIN_934_ISO_4033_table)-1] ) {
    data = DIN_934_ISO_4033_table[i];
    if (screw_debug) { echo( "DIN_934: i ", i, "data: ", data ); }
    if (data[0] == d) {
      color( "silver" )
      difference() {
        cylinder( d=data[2]/cos(180/6), h=data[1], center=false, $fn=6 );
        if (!hull) {
          translate( [0,0,-screw_eps] ) 
            cylinder( d=data[0] + fdm_fudge, h=data[1]+2*screw_eps, center=false, $fn=screw_fn );
        }
      }
      // optional extra-front-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_front_length] )
          cylinder( d=data[2]/cos(180/6), h=extra_front_length, center=false, $fn=6 );
      // optional extra-front-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,data[1]-screw_eps] )
          cylinder( d=data[2]/cos(180/6), h=extra_rear_length, center=false, $fn=6 );
    }
  }
}


module nut_DIN936(
  d=8.0, fdm_fudge=0.2, 
  extra_front_length = 0.0, extra_rear_length = 0.0,
  thread_modeled = false,          
  hull = false,
)
{
  // [mx, m, s ]
  for( i=[0:len(DIN_936_ISO_4035_table)-1] ) {
    data = DIN_936_ISO_4035_table[i];
    if (screw_debug) { echo( "DIN_936: i ", i, "data: ", data ); }
    if (data[0] == d) {
      color( "silver" )
      difference() {
        cylinder( d=data[2]/cos(180/6), h=data[1], center=false, $fn=6 );
        if (!hull) {
          translate( [0,0,-screw_eps] ) 
            cylinder( d=data[0] + fdm_fudge, h=data[1]+2*screw_eps, center=false, $fn=screw_fn );
        }
      }
      // optional extra-front-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_front_length] )
          cylinder( d=data[2]/cos(180/6), h=extra_front_length, center=false, $fn=6 );
      // optional extra-front-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,data[1]-screw_eps] )
          cylinder( d=data[2]/cos(180/6), h=extra_rear_length, center=false, $fn=6 );
    }
  }
}


/**
 * Senkschraube mit Schlitz
 * Mx  metric thread size
 * dk  large head diameter
 *  k  head height
 *  b  thread length (usually full screw length)
 *  n  slot width
 *  t  slot depth
 */
module screw_DIN963( 
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  thread_modeled = false,
  hull = false, 
)
{
  // [mx, dk, k, n, t] = DIN_965_table[...]
  for( i=[0:len(DIN_963_table)-1] ) {
    data = DIN_963_table[i];
    if (screw_debug) { echo( "DIN 963 i ", i, "data: ", data ); }
    if (data[0] == d) {
      d1 = data[1] + fdm_fudge; d2 = data[0] + fdm_fudge; hh = data[2];
      n  = data[4]; t = data[5];
      color( "silver" ) {
        difference() {
          cylinder( d1=d1, d2=d2, h=hh, center=false, $fn=screw_fn );
          if (!hull) {
            translate( [0,0,-screw_eps] ) cube( [n,d1+screw_eps,2*t], center=true );
          }
        }
        translate( [0,0,hh-screw_eps] )
          cylinder( d=d2, h=l-hh+screw_eps, center=false, $fn=screw_fn );
      }
      // optional extra-head-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_head_length] )
          cylinder( d=d1, h=extra_head_length+screw_eps, center=false, $fn=screw_fn );
      // optional extra-thread
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,l-screw_eps] )
          cylinder( d=d2, h=extra_thread_length+screw_eps, center=false, $fn=screw_fn );
    } // if d 
  } // end for 
}



/**
 * Senkschraube mit Ph/PZ/Tx Kreuzschlitz/Torx
 * Mx  metric thread size
 * dk  large head diameter
 *  k  head height
 *  a  distance from head to thread
 *  b  thread length 
 * PZ  pz size
 * PH  phillips size
 * TX  torx size
 *  n  tool depth in head
 */
module screw_DIN965_PH( 
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  thread_modeled = false,
  hull = false,
)
{
  // [mx, dk, k, a, b, n, ph, pz, tx] = DIN_965_table[...]
  for( i=[0:len(DIN_965_table)-1] ) {
    data = DIN_965_table[i];
    if (screw_debug) { echo( "DIN 965 PH i ", i, "data: ", data ); }
    if (data[0] == d) {
      d1 = data[1] + fdm_fudge; d2 = data[0] + fdm_fudge; hh = data[2];
      n  = data[5]; k = data[5];
      color( "silver" ) {
        difference() {
          cylinder( d1=d1, d2=d2, h=hh, center=false, $fn=screw_fn );
          if (!hull) {
            translate( [0,0,-screw_eps] ) cube( [n,d2,2*k], center=true );
            translate( [0,0,-screw_eps] ) cube( [d2,n,2*k], center=true );
          }
        }
        translate( [0,0,hh-screw_eps] )
          cylinder( d=d2, h=l-hh+screw_eps, center=false, $fn=screw_fn );
      }
      // optional extra-head-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_head_length] )
          cylinder( d=d1, h=extra_head_length+screw_eps, center=false, $fn=screw_fn );
      // optional extra-thread
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,l-screw_eps] )
          cylinder( d=d2, h=extra_thread_length+screw_eps, center=false, $fn=screw_fn );
    } // if d 
  } // end for 
}


/**
 * Senkschraube mit Ph/PZ/Tx Kreuzschlitz/Torx
 * Mx  metric thread size
 * dk  large head diameter
 *  k  head height
 *  a  distance from head to thread
 *  b  thread length 
 * PZ  pz size
 * PH  phillips size
 * TX  torx size
 *  n  tool depth in head
 */
module screw_DIN965_TX( 
  d=3.0, l=10.0, fdm_fudge=0.2, 
  extra_head_length = 0.0, extra_thread_length = 0.0,
  thread_modeled = false,
  hull = false, 
)
{
  // [mx, dk, k, a, b, n, ph, pz, tx] = DIN_965_table[...]
  for( i=[0:len(DIN_965_table)-1] ) {
    data = DIN_965_table[i];
    if (screw_debug) { echo( "DIN 965 TX i ", i, "data: ", data ); }
    if (data[0] == d) {
      d1 = data[1] + fdm_fudge; d2 = data[0] + fdm_fudge; hh = data[2];
      n  = data[5]; k = data[5];
      color( "silver" ) {
        difference() {
          cylinder( d1=d1, d2=d2, h=hh, center=false, $fn=screw_fn );
          if (!hull) {
            translate( [0,0,-screw_eps] ) cylinder( d=d2, h=hh, center=false, $fn=3 );
            translate( [0,0,-screw_eps] ) rotate( [0,0,180] ) cylinder( d=d2, h=hh, center=false, $fn=3 );
          }
        }
        translate( [0,0,hh-screw_eps] )
          cylinder( d=d2, h=l-hh+screw_eps, center=false, $fn=screw_fn );
      }
      // optional extra-head-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_head_length] )
          cylinder( d=d1, h=extra_head_length+screw_eps, center=false, $fn=screw_fn );
      // optional extra-thread
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,l-screw_eps] )
          cylinder( d=d2, h=extra_thread_length+screw_eps, center=false, $fn=screw_fn );
    } // if d 
  } // end for 
}


module washer_DIN9021(
  d=3.0, fdm_fudge=0.2, 
  extra_front_length = 0.0, extra_rear_length = 0.0,
  thread_modeled = false, hull = false,
)
{
  // [mx, dk, k, n, t] = DIN_9021_ISO_7093_table[]
  for( i=[0:len(DIN_9021_ISO_7093_table)-1] ) {
    data = DIN_9021_ISO_7093_table[i];
    if (screw_debug) { echo( "DIN_9021: i ", i, "data: ", data ); }
    if (data[0] == d) {
      color( "silver" )
      difference() {
        cylinder( d=data[2], h=data[3], center=false, $fn=screw_fn );
        if (!hull) {
          translate( [0,0,-screw_eps] ) 
            cylinder( d=data[1] + fdm_fudge, h=data[3]+2*screw_eps, center=false, $fn=screw_fn );
        }
      }
      // optional extra-front-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,-extra_front_length] )
          cylinder( d=data[2], h=extra_front_length, center=false, $fn=screw_fn );
      // optional extra-front-cavity
      color( [0.9,0.9,0.7,0.2] )
        translate( [0,0,data[1]-screw_eps] )
          cylinder( d=data[2], h=extra_rear_length, center=false, $fn=screw_fn );
    }
  }
}


/** 
 * Vierkantmuttern (normale Dicke)
 * d = thread diameter = M size
 * s = side length
 * e = edge-to-edge length
 * m = thickness
 */
DIN_557_table = [
 // name d s e m
 [ "M4",   4.0,  7.0,  9.9,  3.2 ],
 [ "M5",   5.0,  8.0, 11.3,  4.0 ],
 [ "M6",   6.0, 10.0, 14.1,  5.0 ],
 [ "M8",   8.0, 13.0, 18.4,  6.5 ],
 [ "M10", 10.0, 17.0, 24.0,  8.0 ],
 [ "M12", 12.0, 19.0, 26.9, 10.0 ],
 [ "M16", 16.0, 24.0, 33.0, 13.0 ],
 ];


/**
 * Vierkantmuttern (dünn), Parameter wie DIN 556
 */
DIN_562_table = [
 // name d s e m
 [ "M1.6", 1.6,  3.2,  4.6,  1.0 ],
 [ "M2",   2.0,  4.0,  5.7,  1.2 ],
 [ "M2.5", 2.5,  5.0,  7.1,  1.6 ],
 [ "M3",   3.0,  5.5,  7.0,  1.8 ],

 [ "M4",   4.0,  7.0,  9.9,  2.2 ],
 [ "M5",   5.0,  8.0, 11.3,  2.7 ],
 [ "M6",   6.0, 10.0, 14.1,  3.2 ],
 [ "M8",   8.0, 13.0, 18.4,  4.0 ],
 [ "M10", 10.0, 17.0, 24.0,  5.0 ],
 ];


 /**
  * cylinder screw with hex driver:
  * d  = thread diameter = M size
  * dk = outer head diameter
  * k  = head height/length
  * l  = total length including head
  * b  = thread length
  * t  = hex hole depth
  * s  = hex hole side-to-side
  * e  = hex hole corner-to-corner
  */
DIN_912_ISO_4762_table = [
 // Mx    dk   k    b,     t, s, e
 [ 1.4,  2.6, 1.4, 10.0,   1.0,  1.3,  1.5 ], // M1.4 hex 1.3
 [ 1.6,  3.0, 1.6, 10.0,   1.3,  1.5,  1.8 ], // M1.6 hex 1.5
 [ 2.0,  3.8, 2.0, 10.0,   1.5,  1.5,  1.8 ], // M2   hex 1.5
 [ 2.5,  4.5, 2.5, 10.0,   2.0,  2.0,  2.3 ], // M2.5 hex 2
 [ 3.0,  5.5, 3.0, 12.0,   2.0,  2.5,  2.87], // M3  hex 2.5
 [ 4.0,  7.0, 4.0, 14.0,   3.0,  3.0,  3.44], // M4  hex 3
 [ 5.0,  8.5, 5.0, 16.0,   4.0,  4.0,  4.58], // M5  hex 4
 [ 6.0, 10.0, 6.0, 18.0,   4.5,  5.0,  5.72], // M6  hex 5
 [ 8.0, 13.0, 8.0, 22.0,   6.0,  6.0,  6.86], // M8  hex 6
 [10.0, 16.0, 10., 26.0,   8.0,  8.0,  9.15], // M10 hex 8
 [12.0, 18.0, 12., 30.0,   10., 10.0, 11.43], // M12 hex 10
 [14.0, 21.0, 14., 30.0,   11., 12.0, 13.72], // M10 hex 8
 [16.0, 24.0, 16., 40.0,   12., 14.0, 16.06], // M16 hex 12
 [20.0, 30.0, 20., 50.0,   15., 17.0, 19.45], // M20 hex 72
];


/**
 * Flachkopfschrauben mit Schlitz, großer Kopf
 * d = thread diameter = M size
 * dk = head diameter
 * k  = head height
 * n  = head slot width
 * t  = head slot depth
 * l  = screw thread length (without head)
 */
DIN_921_table = [ // no matching ISO norm
 // Mx    dk     k      n    t
 [  1.6,  5.0,   1.0,   0.4,  0.5 ], // M 1.6
 [  2.0,  6.0,   1.2,   0.5,  0.6 ], // M 2
 [  2.5,  7.0,   1.5,   0.6,  0.75], // M 2.5
 [  3.0,  8.0,   1.8,   0.8,  0.9 ], // M3
 [  4.0, 12.0,   2.4,   1.0,  1.2 ], // M4
 [  5.0, 16.0,   2.7,   1.2,  1.3 ], // M5
 [  6.0, 20.0,   3.1,   1.6,  1.5 ], // M6
];


/**
 * Sechskantschrauben, Gewinde bis Kopf, mit Schlitz, DIN 933 SZ
 * d = thread diameter = M size
 * dk = head diameter
 * k  = head height
 * n  = head slot width
 * t  = head slot depth
 * l  = screw thread length (without head)
 */
DIN_933_table = [ // no matching ISO norm
 // Mx    dk     k      n    t
 [  3.0,  5.5,   2.0,   0.8,  0.8 ], // M3
 [  4.0,  7.0,   3.0,   1.0,  1.1 ], // M4
 [  5.0,  8.0,   3.5,   1.2,  1.4 ], // M5
 [  6.0, 10.0,   4.0,   1.6,  1.6 ], // M6
 [  8.0, 13.0,   5.3,   2.0,  2.1 ], // M9
 [ 10.0, 17.0,   6.4,   2.0,  2.1 ], // M10
];


/**
 * hex nuts
 * d = thread diameter = M size
 * m = height
 * s = side-to-side size
 * e = edge-to-edge size
 */
DIN_934_ISO_4033_table = [ 
  // Mx    m,    s    e
  [  1.0,  0.8,  2.5, 2.71 ],
  [  1.2,  1.0,  3.0, 3.28 ],
  [  1.4,  1.2,  3.0, 3.28 ],
  [  1.6,  1.3,  3.2, 3.48 ],
  [  1.7,  1.4,  3.5, 4.21 ],
  [  2.0,  1.6,  4.0, 4.38 ], // M2
  [  2.3,  1.8,  4.5, 4.88 ],
  [  2.5,  2.0,  5.0, 5.45 ],
  [  3.0,  2.0,  5.0, 6.08 ],
  [  3.5,  2.8,  6.0, 6.58 ],
  [  4.0,  3.2,  7.0, 7.74 ],
  [  5.0,  4.0,  8.0, 8.63 ],
  [  6.0,  5.0, 10.0, 10.89 ],
  [  7.0,  5.5, 11.0, 12.12 ],
  [  8.0,  6.5, 13.0, 14.20 ],
  [ 10.0,  8.0, 17.0, 18.72 ],
  [ 12.0, 10.0, 19.0, 20.88 ],
  [ 14.0, 11.0, 22.0, 23.91 ],
];


/**
 * hex nuts
 * d = thread diameter = M size
 * m = height
 * s = side-to-side size
 */
DIN_936_ISO_4035_table = [ 
  // Mx    m,    s
  [  8.0,  5.0, 13.0 ],
  [ 10.0,  6.0, 17.0 ],
  [ 12.0,  7.0, 19.0 ],
  [ 14.0,  8.0, 22.0 ],
  [ 16.0,  8.0, 24.0 ],
  [ 18.0,  9.0, 27.0 ],
  [ 20.0,  9.0, 30.0 ],
  [ 22.0, 10.0, 32.0 ],
];


/**
 * Senkschrauben mit Schlitz
 * n = slot width
 * t = slot depth
 */
DIN_963_table = [ // no matching ISO norm, similar to ISO 2009
 // Mx    dk     k        b      n      t
 [  1.0,  1.9,   0.6,     10,    0.25,  0.3  ],
 [  1.2,  2.3,   0.72,    11,    0.3,   0.35 ],
 [  1.4,  2.6,   0.84,    12,    0.3,   0.4  ],
 [  1.6,  3.0,   0.96,    15,    0.4,   0.45 ],
 [  1.7,  3.5,   1.1,     15,    0.5,   0.5  ],
 [  2.0,  3.8,   1.2,     16,    0.5,   0.6  ],
 [  2.3,  4.5,   1.3,     16,    0.6,   0.65 ],
 [  2.5,  4.7,   1.5,     18,    0.6,   0.7  ],
 [  3.0,  5.6,   1.65,    19,    0.8,   0.85 ],
 [  4.0,  7.5,   2.2,     22,    1.0,   1.1  ],
 [  5.0,  9.2,   2.5,     25,    1.2,   1.3  ],
 [  6.0, 11.0,   3.0,     28,    1.6,   1.6  ],
 [  8.0, 14.5,   4.0,     34,    2.0,   2.1  ],
 [ 10.0, 18.0,   5.0,     40,    2.5,   2.6  ],
 [ 12.0, 22.0,   6.0,     46,    3.0,   3.2  ],
];



/**
 * Sechskantschrauben, Gewinde bis Kopf, mit Schlitz, DIN 965 PH/P/TX
 * d = thread diameter = M size
 * dk = head diameter
 * k  = head height
 * a  = distance between head and thread
 * b  = thread length
 * n  = head slot width
 * t  = head slot depth
 * l  = screw thread length (without head)
 * PH = phillips tool size
 * PZ = pozidriv tool size
 * TX = torx size
 */
DIN_965_table = [ // no matching ISO norm, similar to ISO 7046
 // Mx    dk     k      a   b      n   PH  PZ  TX
 [  1.6,  3.0,   0.96,  0.5,  15,    0.4,  0,  0,   0  ],
 [  2.0,  3.8,   1.2,   0.7,  16,    0.5,  1,  1,   1  ],
 [  2.5,  4.7,   1.5,   0.9,  18,    0.6,  1,  1,   1  ],
 [  3.0,  5.6,   1.65,  1.0,  19,    0.8,  1,  1,   1  ],
 [  4.0,  7.5,   2.2,   1.4,  22,    1.0,  2,  2,   2  ],
 [  5.0,  9.2,   2.5,   1.6,  25,    1.2,  2,  2,   2  ],
 [  6.0, 11.0,   3.0,   2.0,  28,    1.6,  3,  3,   3  ],
 [  8.0, 14.5,   4.0,   0,  34,    2.0,  4,  4,   4  ],
 [ 10.0, 18.0,   5.0,   0,  40,    2.5,  4,  4,   4  ],
 [ 12.0, 22.0,   6.0,   0,  46,    3.0,  4,  4,   4  ],
 [ 16.0, 29.0,   8.0,   0,  58,    4.0,  4,  4,   4  ],
 
];





/**
 * countersunk screw with hex driver:
 * d  = thread diameter = M size
 * dk = outer head diameter
 * k  = head height/length
 * l  = total length including head
 * b  = thread length
 * t  = hex hole depth
 * s  = hex hole side-to-side
 * e  = hex hole corner-to-corner
 */
DIN_7991_ISO_10642_table = [
 // Mx    dk   k    b,     t, s, e
 [ 1.6,  3.2, 1.0, 10.0,   0.6,  0.9,  1.1 ], // M1.6 hex 0.9
 [ 2.0,  4.0, 1.2, 10.0,   1.0,  1.3,  1.5 ], // M2  hex 1.3
 [ 2.5,  4.7, 1.5, 10.0,   0.72, 1.5,  1.8 ], // M2.5hex 1.5
 [ 3.0,  6.0, 1.7, 12.0,   1.0,  2.0,  2.3 ], // M3  hex 2.0
 [ 4.0,  8.0, 2.3, 14.0,   1.8,  2.5,  2.87], // M4  hex 2.5
 [ 5.0, 10.0, 2.8, 16.0,   2.3,  3.0,  3.44], // M5  hex 3
 [ 6.0, 12.0, 3.3, 18.0,   2.5,  4.0,  4.58], // M6  hex 4
 [ 8.0, 16.0, 4.4, 22.0,   3.5,  5.0,  5.72], // M8  hex 5
 [10.0, 20.0, 5.5, 26.0,   4.4,  6.0,  6.86], // M10 hex 6
 [12.0, 24.0, 6.5, 30.0,   4.6,  8.0,  9.15], // M12 hex 8
 [16.0, 30.0, 7.5, 38.0,   5.3, 10.0, 11.43], // M16 hex 10
 [20.0, 36.0, 8.5, 46.0,   5.9, 12.0, 13.72], // M20 hex 12
 [24.0, 39.0, 14.0,54.0,  10.3, 14.0, 16.0],  // M24 hex 14
];


/**
 * Scheiben / washer, großer Außendurchmesser = 3x Schraubendurchmesser
 * d2 = outer diameter 
 * d1 = inner diameter (= M size + 0.2)
 * h  = height
 */
DIN_9021_ISO_7093_table = [
  // M    d1   d2   h
  [ 3.0, 3.2,  9.0, 0.8 ],
  [ 3.5, 3.7, 11.0, 0.8 ],
  [ 4.0, 4.3, 12.0, 1.0 ],
  [ 5.0, 5.3, 15.0, 1.2 ],
  [ 6.0, 6.4, 18.0, 1.6 ],
  [ 7.0, 7.4, 22.0, 2.0 ],
  [ 8.0, 8.4, 24.0, 2.0 ],
  [ 10.0, 10.5, 30.0, 2.5 ],
  [ 12.0, 13.0, 37.0, 3.0 ],
  [ 14.0, 15.0, 44.0, 3.0 ],
  [ 16.0, 17.0, 50.0, 3.0 ],
  [ 18.0, 20.0, 56.0, 4.0 ],
  [ 20.0, 22.0, 60.0, 4.0 ],
  [ 22.0, 24,0, 66.0, 5.0 ],
  [ 24.0, 26.0, 72.0, 5.0 ],
  [ 27.0, 30.0, 85,0, 6.0 ],
];


