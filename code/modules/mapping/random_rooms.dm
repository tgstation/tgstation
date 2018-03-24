/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/flippable //Whether this room can function when flipped (i.e. not block doors)
	var/centerspawner = TRUE

/datum/map_template/random_room/pod/greytopia
	name = "Greytopia"
	room_id = "pod_grey"
	mappath = "_maps/RandomRooms/greytopia.dmm"

/datum/map_template/random_room/pod/supplies
	name = "Supply Pod"
	room_id = "pod_supplies"
	mappath = "_maps/RandomRooms/storagepod.dmm"



/datum/map_template/random_room/fivebyfour // As a general rule keep the middle 3 tiles of the long side clear for doors
	centerspawner = FALSE

/datum/map_template/random_room/fivebyfour/dark
	name = "Dark Room"
	room_id = "darkroom"
	mappath = "_maps/RandomRooms/Five-by-Four/darkroom.dmm"

/datum/map_template/random_room/fivebyfour/costume
	name = "Costumes Room"
	room_id = "costumes"
	mappath = "_maps/RandomRooms/Five-by-Four/costumes.dmm"

/datum/map_template/random_room/fivebyfour/surgery
	name = "Abandoned Surgery"
	room_id = "surgery"
	mappath = "_maps/RandomRooms/Five-by-Four/surgery.dmm"

/datum/map_template/random_room/fivebyfour/robotics
	name = "Maint Robotics"
	room_id = "robotics"
	mappath = "_maps/RandomRooms/Five-by-Four/robotics.dmm"

/datum/map_template/random_room/fivebyfour/parlor
	name = "Gaming Parlor"
	room_id = "parlor"
	mappath = "_maps/RandomRooms/Five-by-Four/parlor.dmm"

/datum/map_template/random_room/fivebyfour/electronics
	name = "Electronics Den"
	room_id = "electronics"
	mappath = "_maps/RandomRooms/Five-by-Four/electronics.dmm"

/datum/map_template/random_room/fivebyfour/bedroom
	name = "Luxury Bedroom"
	room_id = "bedroom"
	mappath = "_maps/RandomRooms/Five-by-Four/bedroom.dmm"

/datum/map_template/random_room/fivebyfour/garden
	name = "Wild Garden"
	room_id = "garden"
	mappath = "_maps/RandomRooms/Five-by-Four/garden.dmm"

/datum/map_template/random_room/fivebyfour/dance
	name = "Dance Hall"
	room_id = "dance"
	mappath = "_maps/RandomRooms/Five-by-Four/dance.dmm"

/datum/map_template/random_room/fivebyfour/bathroom
	name = "Maint Bathroom"
	room_id = "bathroom"
	mappath = "_maps/RandomRooms/Five-by-Four/bathroom.dmm"
	flippable = FALSE

/datum/map_template/random_room/fivebyfour/emergency
	name = "Emergency Storage"
	room_id = "emergency"
	mappath = "_maps/RandomRooms/Five-by-Four/emergency.dmm"

/datum/map_template/random_room/fivebyfour/junk
	name = "Scattered Junk"
	room_id = "junk"
	mappath = "_maps/RandomRooms/Five-by-Four/junk.dmm"

/datum/map_template/random_room/fivebyfour/study
	name = "Quiet Study"
	room_id = "study"
	mappath = "_maps/RandomRooms/Five-by-Four/study.dmm"
	flippable = FALSE