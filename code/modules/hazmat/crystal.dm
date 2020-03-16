#define CRYSTAL_SHAPE_SQUARE "square"
#define CRYSTAL_SHAPE_CIRCLE "circle"
#define CRYSTAL_SHAPE_TRIANGLE "triangle"
#define CRYSTAL_SHAPE_CYLINDER "cylinder"

#define CRYSTAL_SIZE_SMALL "small"
#define CRYSTAL_SIZE_MEDIUM "medium"
#define CRYSTAL_SIZE_LARGE "large"

#define CRYSTAL_COLOR_RED "#FF0000"
#define CRYSTAL_COLOR_BLUE "#00FF00"
#define CRYSTAL_COLOR_GREEN "#0000FF

/obj/item/crystal
	name = "anomalous crystal"
	desc = "Do you know who ate all the donuts?"
	icon = 'icons/obj/hazmat/crystals.dmi'
	icon_state = "crystal_square"
	var/crystal_shape = CRYSTAL_SHAPE_SQUARE
	var/crystal_size = CRYSTAL_SIZE_SMALL
	var/crystal_color = CRYSTAL_COLOR_RED
	var/malf_chance = 0

/obj/item/crystal/Initialize()
	. = ..()
	generate_crystal_visuals()

/obj/item/crystal/proc/generate_crystal_visuals()
	icon_state = "crystal_[crystal_shape]"
	color = crystal_color
	switch(crystal_size)
		if(CRYSTAL_SIZE_SMALL)
			transform *= 0.5
		if(CRYSTAL_SIZE_LARGE)
			transform *= 2
	. = ..()

/obj/item/crystal/random/Initialize()
	crystal_shape = pick(CRYSTAL_SHAPE_SQUARE, CRYSTAL_SHAPE_CIRCLE, CRYSTAL_SHAPE_TRIANGLE, CRYSTAL_SHAPE_CYLINDER)
	crystal_size = pick(CRYSTAL_SIZE_SMALL, CRYSTAL_SIZE_MEDIUM, CRYSTAL_SIZE_LARGE)
	crystal_color = pick(CRYSTAL_COLOR_RED, CRYSTAL_COLOR_BLUE, CRYSTAL_COLOR_GREEN)
	. = ..()
