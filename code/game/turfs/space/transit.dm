/turf/space/transit
	var/pushdirection // push things that get caught in the transit tile this direction

//Overwrite because we dont want people building rods in space.
/turf/space/transit/attackby(obj/O as obj, mob/user as mob)
	return

/turf/space/transit/north // moving to the north

	pushdirection = SOUTH  // south because the space tile is scrolling south

	//IF ANYONE KNOWS A MORE EFFICIENT WAY OF MANAGING THESE SPRITES, BE MY GUEST.
	shuttlespace_ns1
		icon_state = "speedspace_ns_1"
	shuttlespace_ns2
		icon_state = "speedspace_ns_2"
	shuttlespace_ns3
		icon_state = "speedspace_ns_3"
	shuttlespace_ns4
		icon_state = "speedspace_ns_4"
	shuttlespace_ns5
		icon_state = "speedspace_ns_5"
	shuttlespace_ns6
		icon_state = "speedspace_ns_6"
	shuttlespace_ns7
		icon_state = "speedspace_ns_7"
	shuttlespace_ns8
		icon_state = "speedspace_ns_8"
	shuttlespace_ns9
		icon_state = "speedspace_ns_9"
	shuttlespace_ns10
		icon_state = "speedspace_ns_10"
	shuttlespace_ns11
		icon_state = "speedspace_ns_11"
	shuttlespace_ns12
		icon_state = "speedspace_ns_12"
	shuttlespace_ns13
		icon_state = "speedspace_ns_13"
	shuttlespace_ns14
		icon_state = "speedspace_ns_14"
	shuttlespace_ns15
		icon_state = "speedspace_ns_15"

/turf/space/transit/east // moving to the east

	pushdirection = WEST

	shuttlespace_ew1
		icon_state = "speedspace_ew_1"
	shuttlespace_ew2
		icon_state = "speedspace_ew_2"
	shuttlespace_ew3
		icon_state = "speedspace_ew_3"
	shuttlespace_ew4
		icon_state = "speedspace_ew_4"
	shuttlespace_ew5
		icon_state = "speedspace_ew_5"
	shuttlespace_ew6
		icon_state = "speedspace_ew_6"
	shuttlespace_ew7
		icon_state = "speedspace_ew_7"
	shuttlespace_ew8
		icon_state = "speedspace_ew_8"
	shuttlespace_ew9
		icon_state = "speedspace_ew_9"
	shuttlespace_ew10
		icon_state = "speedspace_ew_10"
	shuttlespace_ew11
		icon_state = "speedspace_ew_11"
	shuttlespace_ew12
		icon_state = "speedspace_ew_12"
	shuttlespace_ew13
		icon_state = "speedspace_ew_13"
	shuttlespace_ew14
		icon_state = "speedspace_ew_14"
	shuttlespace_ew15
		icon_state = "speedspace_ew_15"