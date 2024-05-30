// Some flavor additions for wolf-related pet commands
/datum/pet_command/good_boy/wolf
	speech_commands = list("good wolf")

/datum/pet_command/follow/wolf
	// Nordic-themed for a bit of extra flavor
	speech_commands = list("heel", "follow", "fylgja", "fyl")

// Contains pixel offset data for sprites riding wolves
/datum/component/riding/creature/wolf

/datum/component/riding/creature/wolf/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 9), TEXT_SOUTH = list(1, 9), TEXT_EAST = list(0, 9), TEXT_WEST = list(2, 9)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)
