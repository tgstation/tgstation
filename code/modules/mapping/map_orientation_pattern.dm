GLOBAL_LIST_INIT(map_orientation_patterns, list(
	TEXT_NORTH = new /datum/map_orientation_pattern/north,
	TEXT_SOUTH = new /datum/map_orientation_pattern/south,
	TEXT_EAST = new /datum/map_orientation_pattern/east,
	TEXT_WEST = new /datum/map_orientation_pattern/west
	))

/**
  * This holds the data the maploader accesses when loading maps in a specific orientation.
  * Why not just hold the data in switch statements?
  * Uhh I dunno, this is prettier and not too much overhead.
  */
/datum/map_orientation_pattern
	var/invert_x
	var/invert_y
	var/swap_xy
	var/xi
	var/yi
	var/turn_angle

/datum/map_orientation_pattern/north
	invert_y = TRUE
	invert_x = TRUE
	swap_xy = FALSE
	xi = -1
	yi = 1
	turn_angle = 180

/datum/map_orientation_pattern/south
	invert_y = FALSE
	invert_x = FALSE
	swap_xy = FALSE
	xi = 1
	yi = -1
	turn_angle = 0

/datum/map_orientation_pattern/east
	invert_y = TRUE
	invert_x = FALSE
	swap_xy = TRUE
	xi = 1
	yi = 1
	turn_angle = 90

/datum/map_orientation_pattern/west
	invert_y = FALSE
	invert_x = TRUE
	swap_xy = TRUE
	xi = -1
	yi = -1
	turn_angle = 270
