/** OpenSCAD model of the ISO-9409-1-50-4-M6 adapter plate,
 * as used on many industrial cobots, e.g. UR3/UR5/UR10, Kuka LWR, ...
 *
 * Based on mechanical drawings from UR documents, plus a low-res scan
 * from research-gate. Dimensions in millimeters.
 * 
 * 2023.03.01 - created
 *
 * (c) 2023 fnh, hendrich@informatik.uni-hamburg.de
 */
 
eps = 0.1;
fudge = 0.1; // FDM overextrusion/shrinking compensation

D1 = 50;   // diameter of screw-bore ring
D2 = 63.0; // outer mounting flange diameter
D3 = 31.5; // diameter of inner bore of mounting flange
N  = 4;    // number of bores
D4 = 6.1;  // M6

translate( [0,0,-15] ) iso9409_1_flange();
translate( [0,0, 15] ) iso9409_1_spacer_ring(); 

 


/* 50-4-M6 robot flange, e.g. LWR-4+, 6mm deep thread bores */
module iso9409_1_flange( D5=90, thickness=15.0, fn=500 ) {
  difference() {
    // main robot tool-flange body
    union() {
      translate( [0,0,0] )
        cylinder( d=90.0, h=thickness-5.0, center=false, $fn=fn );
      translate( [0,0,0] )
        cylinder( d=D2, h=thickness-1, center=false, $fn=fn );     
      translate( [0,0,thickness-1] )
        cylinder( d1=D2, d2=D2-1, h=1, center=false, $fn=fn );     
    }
    // inner bore and extra bevel
    translate( [0,0,thickness+eps-5.0] )
      cylinder( d=D3, h=5.0, center=false, $fn=fn );
    translate( [0,0,thickness+eps-1] )
      cylinder( d1=D3, d2=D3+1, h=1, center=false, $fn=fn );
      
    // screw bores, 6mm deep
    for( alpha=[45,90+45,180+45,270+45] )
      rotate( [0,0,alpha] )
        translate( [D1/2,0,thickness+eps-6.0] )
          cylinder( d=D4, h=6.0, center=false, $fn=100 );
    // through bores, visualization mostly
    for( alpha=[45,90+45,180+45,270+45] )
      rotate( [0,0,alpha] )
        translate( [D1/2,0,-eps] )
          cylinder( d=5.0, h=thickness+2*eps, center=false, $fn=100 );

    // alignment-pin bore
    translate( [D1/2,0,-eps] )
      cylinder( d=6.0, h=thickness+2*eps, center=false, $fn=100 );
  }
}


/**
 * Simple distance ring for the ISO-9409-1-50-4-M6 flange.
 * (For example, use if your screws are a bit too long.)
 */
module iso9409_1_spacer_ring( thickness=4.0, fn=500 ) {
  difference() {
    cylinder( d=D2-fudge, h=thickness, center=false, $fn=fn );    
    translate( [0,0,-eps] )
      cylinder( d=D3+fudge, h=thickness+2*eps, center=false, $fn=fn );
    // screw bores
    for( alpha=[45,90+45,180+45,270+45] )
      rotate( [0,0,alpha] )
        translate( [D1/2,0,-eps] )
          cylinder( d=D4, h=thickness+2*eps, center=false, $fn=100 );
    // alignment-pin bore
    translate( [D1/2,0,-eps] )
      cylinder( d=6.0, h=thickness+2*eps, center=false, $fn=100 );
  }
}
