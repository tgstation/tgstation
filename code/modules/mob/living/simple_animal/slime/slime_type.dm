/datum/slime_type
	///Our slime's colour as text. Used by both description, and icon
	var/colour
	///The type our slime spawns
	var/core_type
	///The possible mutations of our slime
	var/list/mutations

	var/static/list/slime_colours_to_rgb = list(
		SLIME_TYPE_ADAMANTINE = COLOR_SLIME_ADAMANTINE,
		SLIME_TYPE_BLACK = COLOR_SLIME_BLACK,
		SLIME_TYPE_BLUE = COLOR_SLIME_BLUE,
		SLIME_TYPE_BLUESPACE = COLOR_SLIME_BLUESPACE,
		SLIME_TYPE_CERULEAN = COLOR_SLIME_CERULEAN,
		SLIME_TYPE_DARK_BLUE = COLOR_SLIME_DARK_BLUE,
		SLIME_TYPE_DARK_PURPLE = COLOR_SLIME_DARK_PURPLE,
		SLIME_TYPE_GOLD = COLOR_SLIME_GOLD,
		SLIME_TYPE_GREEN = COLOR_SLIME_GREEN,
		SLIME_TYPE_GREY = COLOR_SLIME_GREY,
		SLIME_TYPE_LIGHT_PINK = COLOR_SLIME_LIGHT_PINK,
		SLIME_TYPE_METAL = COLOR_SLIME_METAL,
		SLIME_TYPE_OIL = COLOR_SLIME_OIL,
		SLIME_TYPE_ORANGE = COLOR_SLIME_ORANGE,
		SLIME_TYPE_PINK = COLOR_SLIME_PINK,
		SLIME_TYPE_PURPLE = COLOR_SLIME_PURPLE,
		SLIME_TYPE_PYRITE = COLOR_SLIME_PYRITE,
		SLIME_TYPE_RAINBOW = COLOR_SLIME_RAINBOW,
		SLIME_TYPE_RED = COLOR_SLIME_RED,
		SLIME_TYPE_SEPIA = COLOR_SLIME_SEPIA,
		SLIME_TYPE_SILVER = COLOR_SLIME_SILVER,
		SLIME_TYPE_YELLOW = COLOR_SLIME_YELLOW,
	)

/datum/slime_type/proc/get_rgb()
	return slime_colours_to_rgb[colour]

//TIER 0

/datum/slime_type/grey
	colour = SLIME_TYPE_GREY
	core_type = /obj/item/slime_extract/grey
	mutations = list(
		/datum/slime_type/orange = 1,
		/datum/slime_type/metal = 1,
		/datum/slime_type/blue = 1,
		/datum/slime_type/purple = 1,)

//TIER 1

/datum/slime_type/blue
	colour = SLIME_TYPE_BLUE
	core_type = /obj/item/slime_extract/blue
	mutations = list(
		/datum/slime_type/darkblue = 1,
		/datum/slime_type/silver = 1,
		/datum/slime_type/pink = 2,)

/datum/slime_type/metal
	colour = SLIME_TYPE_METAL
	core_type = /obj/item/slime_extract/metal
	mutations = list(
		/datum/slime_type/silver = 1,
		/datum/slime_type/yellow = 1,
		/datum/slime_type/gold = 2,)

/datum/slime_type/purple
	colour = SLIME_TYPE_PURPLE
	core_type = /obj/item/slime_extract/purple
	mutations = list(
		/datum/slime_type/darkpurple = 1,
		/datum/slime_type/darkblue = 1,
		/datum/slime_type/green = 2,)

/datum/slime_type/orange
	colour = SLIME_TYPE_ORANGE
	core_type = /obj/item/slime_extract/orange
	mutations = list(
		/datum/slime_type/darkpurple = 1,
		/datum/slime_type/yellow = 1,
		/datum/slime_type/red = 2,)

//TIER 2

/datum/slime_type/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	core_type = /obj/item/slime_extract/darkblue
	mutations = list(
		/datum/slime_type/purple = 1,
		/datum/slime_type/blue = 1,
		/datum/slime_type/cerulean = 2,)

/datum/slime_type/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	core_type = /obj/item/slime_extract/darkpurple
	mutations = list(
		/datum/slime_type/purple = 1,
		/datum/slime_type/orange = 1,
		/datum/slime_type/sepia = 2,)
	mutations = list(SLIME_TYPE_PURPLE = 1, SLIME_TYPE_ORANGE = 1, SLIME_TYPE_SEPIA = 2)

/datum/slime_type/silver
	colour = SLIME_TYPE_SILVER
	core_type = /obj/item/slime_extract/silver
	mutations = list(
		/datum/slime_type/metal = 1,
		/datum/slime_type/blue = 1,
		/datum/slime_type/pyrite = 2,)
	mutations = list(SLIME_TYPE_METAL = 1, SLIME_TYPE_BLUE = 1, SLIME_TYPE_PYRITE = 2)

/datum/slime_type/yellow
	colour = SLIME_TYPE_YELLOW
	core_type = /obj/item/slime_extract/yellow
	mutations = list(
		/datum/slime_type/metal = 1,
		/datum/slime_type/orange = 1,
		/datum/slime_type/bluespace = 2,)

//TIER 3

/datum/slime_type/bluespace
	colour = SLIME_TYPE_BLUESPACE
	core_type = /obj/item/slime_extract/bluespace
	mutations = list(/datum/slime_type/bluespace = 1,)

/datum/slime_type/cerulean
	colour = SLIME_TYPE_CERULEAN
	core_type = /obj/item/slime_extract/cerulean
	mutations = list(/datum/slime_type/cerulean = 1,)

/datum/slime_type/pyrite
	colour = SLIME_TYPE_PYRITE
	core_type = /obj/item/slime_extract/pyrite
	mutations = list(/datum/slime_type/pyrite = 1,)

/datum/slime_type/sepia
	colour = SLIME_TYPE_SEPIA
	core_type = /obj/item/slime_extract/sepia
	mutations = list(/datum/slime_type/sepia = 1,)


//TIER 4

/datum/slime_type/gold
	colour = SLIME_TYPE_GOLD
	core_type = /obj/item/slime_extract/gold
	mutations = list(
		/datum/slime_type/gold = 2,
		/datum/slime_type/adamantine = 2,)

/datum/slime_type/green
	colour = SLIME_TYPE_GREEN
	core_type = /obj/item/slime_extract/green
	mutations = list(
		/datum/slime_type/green = 2,
		/datum/slime_type/black = 2,)

/datum/slime_type/pink
	colour = SLIME_TYPE_PINK
	core_type = /obj/item/slime_extract/pink
	mutations = list(
		/datum/slime_type/pink = 2,
		/datum/slime_type/lightpink = 2,)

/datum/slime_type/red
	colour = SLIME_TYPE_RED
	core_type = /obj/item/slime_extract/red
	mutations = list(
		/datum/slime_type/red = 2,
		/datum/slime_type/oil = 2,)

//TIER 5

/datum/slime_type/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	core_type = /obj/item/slime_extract/adamantine
	mutations = list(/datum/slime_type/adamantine = 1,)

/datum/slime_type/black
	colour = SLIME_TYPE_BLACK
	core_type = /obj/item/slime_extract/black
	mutations = list(/datum/slime_type/black = 1,)

/datum/slime_type/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	core_type = /obj/item/slime_extract/lightpink
	mutations = list(/datum/slime_type/lightpink = 1,)

/datum/slime_type/oil
	colour = SLIME_TYPE_OIL
	core_type = /obj/item/slime_extract/oil
	mutations = list(/datum/slime_type/oil = 1,)

//Tier Special

/datum/slime_type/rainbow
	colour = SLIME_TYPE_RAINBOW
	core_type = /obj/item/slime_extract/rainbow
	mutations = list(/datum/slime_type/rainbow = 1,)
