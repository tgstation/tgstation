/// Parallax layers that vary between rounds. Has some code to make sure we all have the same one
/atom/movable/screen/parallax_layer/random
	blend_mode = BLEND_OVERLAY
	speed = 2
	layer = 3

/atom/movable/screen/parallax_layer/random/Initialize(mapload, datum/hud/hud_owner, template, atom/movable/screen/parallax_layer/random/twin)
	. = ..()

	if(twin)
		copy_parallax(twin)

/// Make this layer unique, with color or position or something
/atom/movable/screen/parallax_layer/random/proc/get_random_look()
	return

/// Copy a parallax instance to ensure parity between everyones parallax
/atom/movable/screen/parallax_layer/random/proc/copy_parallax(atom/movable/screen/parallax_layer/random/twin)
	return

/// For applying minor effects related to parallax. If you want big stuff, put it in a station trait or something
/atom/movable/screen/parallax_layer/random/proc/apply_global_effects()
	return

/// Gassy background with a few random colors
/atom/movable/screen/parallax_layer/random/space_gas
	icon_state = "space_gas"

	/// The colors we can be
	var/possible_colors = list(COLOR_TEAL, COLOR_GREEN, COLOR_SILVER, COLOR_YELLOW, COLOR_CYAN, COLOR_ORANGE, COLOR_PURPLE)
	/// The color we are
	var/parallax_color

/atom/movable/screen/parallax_layer/random/space_gas/get_random_look()
	parallax_color = parallax_color || pick(possible_colors)

/atom/movable/screen/parallax_layer/random/space_gas/copy_parallax(atom/movable/screen/parallax_layer/random/space_gas/twin)
	parallax_color = twin.parallax_color
	add_atom_colour(parallax_color, ADMIN_COLOUR_PRIORITY)

/// Space gas but green for the radioactive nebula station trait
/atom/movable/screen/parallax_layer/random/space_gas/radioactive
	parallax_color = list(0,0,0,0, 0,2,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //very vibrant green

/atom/movable/screen/parallax_layer/random/space_gas/radioactive/apply_global_effects()
	. = ..()
	set_base_starlight("#189156")

/// Big asteroid rocks appear in the background
/atom/movable/screen/parallax_layer/random/asteroids
	icon_state = "asteroids"
	layer = 4
