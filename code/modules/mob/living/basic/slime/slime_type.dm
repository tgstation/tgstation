/datum/slime_type
	///Our slime's colour as text. Used by both description, and icon
	var/colour
	///Whether the slime icons should be semi-transparent
	var/transparent = FALSE
	///The type our slime spawns
	var/core_type
	///The possible mutations of our slime
	var/list/mutations
	///The hexcode used by the slime to colour their victims
	var/rgb_code

/datum/slime_type/Destroy(force)
	if(!force)
		stack_trace("Something tried to delete a \"/datum/slime_type\", this should never happen as could lead to slime colors being broken!")
		return QDEL_HINT_LETMELIVE
	return ..()

//TIER 0

/datum/slime_type/grey
	colour = SLIME_TYPE_GREY
	transparent = TRUE
	core_type = /obj/item/slime_extract/grey
	mutations = list(
		/datum/slime_type/blue = 1,
		/datum/slime_type/metal = 1,
		/datum/slime_type/orange = 1,
		/datum/slime_type/purple = 1,
	)
	rgb_code = COLOR_SLIME_GREY

//TIER 1

/datum/slime_type/blue
	colour = SLIME_TYPE_BLUE
	transparent = TRUE
	core_type = /obj/item/slime_extract/blue
	mutations = list(
		/datum/slime_type/darkblue = 1,
		/datum/slime_type/pink = 2,
		/datum/slime_type/silver = 1,
	)
	rgb_code = COLOR_SLIME_BLUE

/datum/slime_type/metal
	colour = SLIME_TYPE_METAL
	core_type = /obj/item/slime_extract/metal
	mutations = list(
		/datum/slime_type/gold = 2,
		/datum/slime_type/silver = 1,
		/datum/slime_type/yellow = 1,
	)
	rgb_code = COLOR_SLIME_METAL

/datum/slime_type/purple
	colour = SLIME_TYPE_PURPLE
	transparent = TRUE
	core_type = /obj/item/slime_extract/purple
	mutations = list(
		/datum/slime_type/darkblue = 1,
		/datum/slime_type/darkpurple = 1,
		/datum/slime_type/green = 2,
	)
	rgb_code = COLOR_SLIME_PURPLE

/datum/slime_type/orange
	colour = SLIME_TYPE_ORANGE
	transparent = TRUE
	core_type = /obj/item/slime_extract/orange
	mutations = list(
		/datum/slime_type/darkpurple = 1,
		/datum/slime_type/red = 2,
		/datum/slime_type/yellow = 1,
	)
	rgb_code = COLOR_SLIME_ORANGE

//TIER 2

/datum/slime_type/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	transparent = TRUE
	core_type = /obj/item/slime_extract/darkblue
	mutations = list(
		/datum/slime_type/blue = 1,
		/datum/slime_type/cerulean = 2,
		/datum/slime_type/purple = 1,
	)
	rgb_code = COLOR_SLIME_BLUE

/datum/slime_type/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	core_type = /obj/item/slime_extract/darkpurple
	mutations = list(
		/datum/slime_type/orange = 1,
		/datum/slime_type/purple = 1,
		/datum/slime_type/sepia = 2,
	)
	rgb_code = COLOR_SLIME_PURPLE

/datum/slime_type/silver
	colour = SLIME_TYPE_SILVER
	core_type = /obj/item/slime_extract/silver
	mutations = list(
		/datum/slime_type/blue = 1,
		/datum/slime_type/metal = 1,
		/datum/slime_type/pyrite = 2,
	)
	rgb_code = COLOR_SLIME_SILVER

/datum/slime_type/yellow
	colour = SLIME_TYPE_YELLOW
	transparent = TRUE
	core_type = /obj/item/slime_extract/yellow
	mutations = list(
		/datum/slime_type/bluespace = 2,
		/datum/slime_type/metal = 1,
		/datum/slime_type/orange = 1,
	)
	rgb_code = COLOR_SLIME_YELLOW

//TIER 3

/datum/slime_type/bluespace
	colour = SLIME_TYPE_BLUESPACE
	core_type = /obj/item/slime_extract/bluespace
	mutations = list(
		/datum/slime_type/bluespace = 1,
	)
	rgb_code = COLOR_SLIME_BLUESPACE


/datum/slime_type/cerulean
	colour = SLIME_TYPE_CERULEAN
	transparent = TRUE
	core_type = /obj/item/slime_extract/cerulean
	mutations = list(
		/datum/slime_type/cerulean = 1,
	)
	rgb_code = COLOR_SLIME_CERULEAN

/datum/slime_type/pyrite
	colour = SLIME_TYPE_PYRITE
	core_type = /obj/item/slime_extract/pyrite
	mutations = list(
		/datum/slime_type/pyrite = 1,
	)
	rgb_code = COLOR_SLIME_PYRITE

/datum/slime_type/sepia
	colour = SLIME_TYPE_SEPIA
	transparent = TRUE
	core_type = /obj/item/slime_extract/sepia
	mutations = list(
		/datum/slime_type/sepia = 1,
	)
	rgb_code = COLOR_SLIME_SEPIA

//TIER 4

/datum/slime_type/gold
	colour = SLIME_TYPE_GOLD
	core_type = /obj/item/slime_extract/gold
	mutations = list(
		/datum/slime_type/adamantine = 1,
		/datum/slime_type/gold = 1,
	)
	rgb_code = COLOR_SLIME_GOLD

/datum/slime_type/green
	colour = SLIME_TYPE_GREEN
	transparent = TRUE
	core_type = /obj/item/slime_extract/green
	mutations = list(
		/datum/slime_type/black = 1,
		/datum/slime_type/green = 1,
	)
	rgb_code = COLOR_SLIME_GREEN

/datum/slime_type/pink
	colour = SLIME_TYPE_PINK
	transparent = TRUE
	core_type = /obj/item/slime_extract/pink
	mutations = list(
		/datum/slime_type/lightpink = 1,
		/datum/slime_type/pink = 1,
	)
	rgb_code = COLOR_SLIME_PINK

/datum/slime_type/red
	colour = SLIME_TYPE_RED
	transparent = TRUE
	core_type = /obj/item/slime_extract/red
	mutations = list(
		/datum/slime_type/oil = 1,
		/datum/slime_type/red = 1,
	)
	rgb_code = COLOR_SLIME_RED

//TIER 5

/datum/slime_type/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	core_type = /obj/item/slime_extract/adamantine
	mutations = list(
		/datum/slime_type/adamantine = 1,
	)
	rgb_code = COLOR_SLIME_ADAMANTINE

/datum/slime_type/black
	colour = SLIME_TYPE_BLACK
	transparent = TRUE
	core_type = /obj/item/slime_extract/black
	mutations = list(
		/datum/slime_type/black = 1,
	)
	rgb_code = COLOR_SLIME_BLACK

/datum/slime_type/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	transparent = TRUE
	core_type = /obj/item/slime_extract/lightpink
	mutations = list(
		/datum/slime_type/lightpink = 1,
	)
	rgb_code = COLOR_SLIME_LIGHT_PINK

/datum/slime_type/oil
	colour = SLIME_TYPE_OIL
	core_type = /obj/item/slime_extract/oil
	mutations = list(
		/datum/slime_type/oil = 1,
	)
	rgb_code = COLOR_SLIME_OIL

//Tier Special

/datum/slime_type/rainbow
	colour = SLIME_TYPE_RAINBOW
	transparent = TRUE
	core_type = /obj/item/slime_extract/rainbow
	mutations = list(
		/datum/slime_type/rainbow = 1,
	)
	rgb_code = COLOR_SLIME_RAINBOW
