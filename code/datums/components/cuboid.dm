/datum/component/cuboid
	///Rarity of the cube
	var/rarity = COMMON_CUBE
	/// Name of the cube's rarity
	var/rarity_name = "Common"
	/// Color of the cube's rarity.
	var/rarity_color_name = "white"
	var/rarity_color = COLOR_WHITE
	/// Unless there's some way to have the defines ALSO have names w/ the numbers, this is the best I can get lol
	var/static/list/all_rarenames = list(
		span_bold("Common"),
		span_boldnicegreen("Uncommon"),
		span_boldnotice("Rare"),
		span_hierophant("Epic"),
		span_bolddanger("Legendary"),
		span_clown("Mythical")
		)
	/// Same as above but with colors
	var/static/list/all_rarecolors = list(
		"white" = COLOR_WHITE,
		"green" = COLOR_VIBRANT_LIME,
		"blue" = COLOR_DARK_CYAN,
		"purple" = COLOR_PURPLE,
		"red" = COLOR_RED,
		"pink" = COLOR_PINK
		)


/datum/component/cuboid/Initialize(mapload, cube_rarity = COMMON_CUBE)
	/// Rarity
	src.rarity = cube_rarity
	/// We love indexes!!!
	src.rarity_name = all_rarenames[src.rarity]
	src.rarity_color_name = all_rarecolors[src.rarity]
	src.rarity_color = all_rarecolors[src.rarity_color_name]

/datum/component/cuboid/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))

/datum/component/cuboid/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE
	))

/datum/component/cuboid/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/a_an = "a"
	if(src.rarity == UNCOMMON_CUBE || src.rarity == EPIC_CUBE)
		a_an = "an"
	var/cube_examine = ""
	if(rarity == COMMON_CUBE)
		cube_examine = boxed_message("It's a [src.rarity_name] Cube!")
	else:
		cube_examine = custom_boxed_message("[src.rarity_color_name]_box", "It's [a_an] [src.rarity_name] Cube!")
	examine_list += cube_examine
