sensor_housing_d=5.0;
sensor_housing_h=3.0;
sensor_width=1.0;
sensor_separation=sensor_housing_d + 2.0;

cap_d=21.0;
cap_wall=2.0;
cap_depth=20.0;
cap_outer_lip=2.0;

module tube(d,h,wall){
	difference(){
		cylinder(d=d,h=h);
		translate([0,0,-0.5])
			cylinder(d=d-2*wall,h=h+1);
	}
}

module base_centered_cube(x,y,z){
	translate([-x/2.0,-y/2.0,-z/2.0]) cube([x,y,z]);
}

module wedge(b,h,width){
	half_b = b/2.0;
	rotate([90.0,0,0])
	translate([0,0,-width/2.0])
	linear_extrude(width)
		polygon(points=[[-half_b,0],[0,h],[half_b,0]],paths=[[0,1,2]]);
}

module sensor_void(d,lip,height=5){
	union(){
		translate([0,0,-height])
			cylinder(d=d,h=height);
		translate([0,0,-0.1])
			cylinder(d=d-2*lip,h=height+0.1);
	}
}

$fn=100;

//wedge(sensor_housing_d-2.0,10,5);


//SENSOR CAP
difference(){
	union(){
		//North Indicator
		translate([0,cap_d/2 - 1,-5]) cube([2,5,5],center=true);
		tube(cap_d,cap_depth,1);
		for(j=[0:1])
			rotate([0,0,j*90.0]) wedge(sensor_separation-2.0,10,cap_d-1);
		translate([0,0,-4]) cylinder(d=cap_d+2.0*cap_outer_lip,h=5);
	}

	for(i=[0:3]){
		rotate([0,0,45.0 + i*90.0])
			translate([sensor_separation/sqrt(2.0),0,0])
				sensor_void(sensor_housing_d,1);
	}
}


foo_h=5;
translate([30,0,0]){
	
	difference(){
	union(){
		for(j=[0:3]) rotate([0,0,j*90.0])translate([0,cap_d/2+2,-5]) cube([2,5,5],center=true);
		tube(cap_d,cap_depth,1);
		translate([0,0,-4]) cylinder(d=cap_d+2.0*cap_outer_lip,h=5);
		
	}
	translate([0,0,-foo_h/2+1]) cylinder(d1=20,d2=sensor_separation*sqrt(2),h=foo_h+0.1,center=true);
	}
}