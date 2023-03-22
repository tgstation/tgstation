/datum/map_template/random_room
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0

	///The weight this room has in the random-selection process.
	///Higher weights are more likely to be picked.
	///10 is the default weight. 20 is twice more likely; 5 is half as likely as default.
	///0 here does NOT disable the spawn, it just makes it extremely unlikely
	var/weight = 10
	///how many times this room can appear in a round
	var/stock = 1
