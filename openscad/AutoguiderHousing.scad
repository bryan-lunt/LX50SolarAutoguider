BOARD_WIDTH	=5.2;
BOARD_LENGTH	=7.4;
BOARD_THICK	=0.2;
BOARD_HEIGHT	=2.3;
BOARD_BELOW	=0.3;

additional_length=2.54*0.5;

CORNER_HOLE_INSET=0.5;
HOLE_DIAMETER	=0.3;

jack_width		=1.23;
jack_height		=1.47;
jack_inset		=0.4;
jack_depth		=1.3;
jack_stickout	=0.31;
jack_slack		=0.05;

power_inner_diameter=0.37;
power_outer_diameter=0.65;
power_jack_width=1.16;
power_jack_inset=0.18;
power_jack_center_inset=power_jack_inset + power_jack_width/2.0;
power_jack_stickout = 0.3;

button_hole_diameter=0.97;
button_height=1.2+button_hole_diameter/2.0;

BOX_WALL=0.2;
BOX_FLOOR=0.3;
TOP_OVERHANG=0.2;

snap_height=0.07;//TOP_OVERHANG/2.0;

hole_positions_in_inches = [[0.15,2.7,0.0],
[1.85,2.7,0.0],
[1.85,0.55,0.0],
[1.15, 0.25,0.0],
[0.75, 0.25,0.0]];

in_to_cm=2.54;

$fn=20;

module board_blank(){

	translate([-BOARD_WIDTH/2.0, 0.0, 0.0])
	union(){
		cube(size=[BOARD_WIDTH,BOARD_LENGTH,BOARD_THICK]);
	
		translate([power_jack_center_inset, -power_jack_stickout, BOARD_THICK + power_outer_diameter/2.0]){
			rotate([-90.0,0.0,0.0]) cylinder(d=power_outer_diameter);
			translate([0.0,1.02, 0.0]) cube([1.2,1.4,power_outer_diameter],center=true);
		}

		translate([BOARD_WIDTH-(jack_width+jack_inset)-jack_slack,-jack_stickout, BOARD_THICK-jack_slack])
			cube(size=[jack_width+jack_slack*2.0, jack_depth, jack_height+jack_slack*2.0]);

		//Hole for BUTTON
		translate([BOARD_WIDTH/2.0, -1.5, button_height])
		rotate([-90.0, 0.0, 0.0]){
			cylinder(d=button_hole_diameter, h=3);
			//Notch
			translate([0,-button_hole_diameter/2.0,1.5])
				cube(size=[0.15,0.3,3],center=true);
		}
	}

}

module top_box(){
	overhang_for_difference = 0.5;
	difference(){
		//OUTSIDE BOX
		translate([-BOARD_WIDTH/2.0 - BOX_WALL, -BOX_WALL, -BOX_FLOOR - BOARD_BELOW - TOP_OVERHANG])
			cube(size=[BOARD_WIDTH+2.0*BOX_WALL, BOARD_LENGTH +2.0*BOX_WALL+additional_length, BOARD_THICK+BOARD_HEIGHT+BOARD_BELOW + BOX_WALL + BOX_FLOOR + TOP_OVERHANG]);
		//VOID inside BOX
		translate([-BOARD_WIDTH/2.0, 0.0, -BOARD_BELOW-BOX_FLOOR-overhang_for_difference - TOP_OVERHANG])
			cube(size=[BOARD_WIDTH, BOARD_LENGTH+additional_length, BOARD_THICK+BOARD_HEIGHT+BOARD_BELOW+BOX_FLOOR+overhang_for_difference+ TOP_OVERHANG]);
	}

	//SNAPS
	for(i = [-1, 1]){
	translate([i*BOARD_WIDTH/2.0, (BOARD_LENGTH+additional_length)/2.0, -BOARD_BELOW - BOX_FLOOR - snap_height])
		rotate([-90.0,0.0,0.0]) cylinder(d=snap_height*2.0,h=1.0, center=true);
	}
}


module bottom_plate_hole_support(x,y,d,h){
	d2 = d+0.2;
	translate([x,y,0.0]){
		union(){
			cylinder(d=d, h=BOARD_BELOW+h);
			translate([-0.05, -0.3, 0.0]) cube(size=[0.1, 0.6, BOARD_BELOW]);
		}
	}
}

module bottom_plate(){
	plate_length = BOARD_LENGTH + additional_length;

	translate([0.0, 0.0, -BOARD_BELOW]){
		//The pegs
		translate([-BOARD_WIDTH/2.0,0,0])
		for(i=[0:len(hole_positions_in_inches)-1]){
			bottom_plate_hole_support(in_to_cm*hole_positions_in_inches[i][0], in_to_cm*hole_positions_in_inches[i][1], d=HOLE_DIAMETER, h=0.3);
		}
		//Special support peg that does not go through.
		bottom_plate_hole_support(0.0, BOARD_LENGTH/2.0, d=HOLE_DIAMETER, h=0.0);

	//The bottom plate itself.
		translate([-BOARD_WIDTH/2.0, 0.0, -BOX_FLOOR]){
			cube([BOARD_WIDTH, plate_length, BOX_FLOOR]);
			//The feet
			difference(){
				for(z = [-1, 1]){
					translate([BOARD_WIDTH/2.0 , plate_length/2.0, BOX_FLOOR/2.0])
						rotate([0.0, z*30, 0.0])
							translate([z*1.5/2.0, 0.0, 0.0])
							cube([1.5, plate_length, BOX_FLOOR],center=true);
				}
				for(z = [1.0, BOARD_LENGTH-2.0])
				translate([0.0, z, -BOX_FLOOR/2.0 - 0.06]) cube([10,1,0.2]);
			}
		}
	}
}


	
module full_top_box(){
	//TOP BOX STUFF
	color("blue")
	union(){
	difference(){
		top_box();
		board_blank();
		union(){
			sphere(d=1.2);
			translate([0,0,-10]) cylinder(d=1.2, h=10);
		}
	}
	difference(){
		union(){
			sphere(d=1.2+BOX_WALL);
			translate([0,0,-BOARD_BELOW-BOX_FLOOR-TOP_OVERHANG]) cylinder(d=1.2+BOX_WALL, h=BOARD_BELOW+BOX_FLOOR+TOP_OVERHANG);
		}
		union(){
			translate([-10,0,-10]) cube(size=[20,20,20]);
			translate([0,0,-10-BOARD_BELOW-BOX_FLOOR-TOP_OVERHANG]) cube(size=[20,20,20],center=true);
			sphere(d=1.2);
			translate([0,0,-10]) cylinder(d=1.2, h=10);
		}
	}
	}
}

//MAIN
	scale(1/2.54){
	full_top_box();
	% board_blank();
	//bottom_plate();
	//TUBE
	% translate([0,0,-2.1]) rotate([-90,0,0]) cylinder(d=2.54,h=9);
}
