/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"

/datum/game_mode/blob/pre_setup()
	world << "NO"
	qdel(world)
