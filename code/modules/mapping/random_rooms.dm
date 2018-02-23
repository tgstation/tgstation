/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned

/datum/map_template/random_room/pod/greytopia
	name = "Greytopia"
	room_id = "pod_grey"
	mappath = "_maps/templates/greytopia.dmm"

/datum/map_template/random_room/pod/supplies
	name = "Supply Pod"
	room_id = "pod_supplies"
	mappath = "_maps/templates/storagepod.dmm"



/datum/map_template/random_room/fivebyfour // As a general rule keep the middle 3 tiles of the long edges clear for doors

/datum/map_template/random_room/fivebyfour/dark
	name = "Dark Room"
	room_id = "darkroom"
	mappath = "_maps/templates/darkroom.dmm"

/datum/map_template/random_room/fivebyfour/costume
	name = "Costumes Room"
	room_id = "costumes"
	mappath = "_maps/templates/costumes.dmm"

/datum/map_template/random_room/fivebyfour/surgery
	name = "Abandoned Surgery"
	room_id = "surgery"
	mappath = "_maps/templates/surgery.dmm"

/datum/map_template/random_room/fivebyfour/robotics
	name = "Maint Robotics"
	room_id = "robotics"
	mappath = "_maps/templates/robotics.dmm"

/datum/map_template/random_room/fivebyfour/parlor
	name = "Gaming Parlor"
	room_id = "parlor"
	mappath = "_maps/templates/parlor.dmm"

/datum/map_template/random_room/fivebyfour/electronics
	name = "Electronics Den"
	room_id = "electronics"
	mappath = "_maps/templates/electronics.dmm"

/datum/map_template/random_room/fivebyfour/bedroom
	name = "Luxury Bedroom"
	room_id = "bedroom"
	mappath = "_maps/templates/bedroom.dmm"

/datum/map_template/random_room/fivebyfour/garden
	name = "Wild Garden"
	room_id = "garden"
	mappath = "_maps/templates/garden.dmm"