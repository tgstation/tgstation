

//Generic away mission slot, this one never actually exists.
/area/away
	name = "Away Mission"
	has_gravity = 1 //We can change this later if need be.
	requires_power = 0
	var/slot = 0
	var/datum/away_slot/slot_dat = null //The slot datum associated with this area. These MUST be linked together.
	var/x_start = 0
	var/y_start = 0


/area/away/slot_1
	slot = 1
	icon_state = "awaycontent1"
	x_start = 71
	y_start = 112

/area/away/slot_2
	slot = 2
	icon_state = "awaycontent2"
	x_start = 122
	y_start = 112

/area/away/slot_3
	slot = 3
	icon_state = "awaycontent3"
	x_start = 80
	y_start = 91

/area/away/slot_4
	slot = 4
	icon_state = "awaycontent4"
	x_start = 101
	y_start = 91

/area/away/slot_5
	slot = 5
	icon_state = "awaycontent5"
	x_start = 122
	y_start = 91

/area/away/slot_6
	slot = 6
	icon_state = "awaycontent6"
	x_start = 143
	y_start = 91

/area/away/slot_7
	slot = 7
	icon_state = "awaycontent7"
	x_start = 80
	y_start = 70

/area/away/slot_8
	slot = 8
	icon_state = "awaycontent8"
	x_start = 101
	y_start = 70

/area/away/slot_9
	slot = 9
	icon_state = "awaycontent9"
	x_start = 122
	y_start = 70

/area/away/slot_10
	slot = 10
	icon_state = "awaycontent10"
	x_start = 143
	y_start = 70

/datum/away_slot //An away mission square, on Z.4. There should be 10 of these. 1-2 are large.
	var/num = 0
	var/players_here = 0
	var/size_x = 20
	var/size_y = 20
	var/x_start = 0
	var/y_start = 0
	var/z_start = 0
	var/z_end = 0
	var/x_end = 0
	var/y_end = 0
	var/area/away/area = null
	var/in_use = 0

