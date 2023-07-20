/atom/movable/screen/parallax_layer/random
	blend_mode = BLEND_OVERLAY
	speed = 3
	layer = 3

/atom/movable/screen/parallax_layer/random/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/parallax_layer/random/twin)
	. = ..()

	if(twin)
		copy_parallax(twin)

/// Make this layer unique, with color or position or something
/atom/movable/screen/parallax_layer/random/proc/get_random_look()

/// Copy a parallax instance to ensure parity between everyones parallax
/atom/movable/screen/parallax_layer/random/proc/copy_parallax(atom/movable/screen/parallax_layer/random/twin)

/// For applying minor effects related to parallax. If you want big stuff, put it in a station trait or something
/atom/movable/screen/parallax_layer/random/proc/apply_global_effects()

/atom/movable/screen/parallax_layer/random/space_gas
	icon_state = "space_gas"

	/// The colors we can be
	var/possible_colors = list(COLOR_TEAL, COLOR_GREEN, COLOR_SILVER, COLOR_YELLOW, COLOR_CYAN, COLOR_ORANGE, COLOR_PURPLE)
	/// The color we are
	var/parallax_color

/atom/movable/screen/parallax_layer/random/space_gas/get_random_look()
	parallax_color = pick(possible_colors)

/atom/movable/screen/parallax_layer/random/space_gas/copy_parallax(atom/movable/screen/parallax_layer/random/space_gas/twin)
	parallax_color = twin.parallax_color
	add_atom_colour(parallax_color, ADMIN_COLOUR_PRIORITY)

/atom/movable/screen/parallax_layer/random/asteroids
	icon_state = "asteroids"
	layer = 4
