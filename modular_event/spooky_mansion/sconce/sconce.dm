/obj/structure/mansion/sconce
	name = "sconce"
	desc = "A wall sconce."
	icon = 'modular_event/spooky_mansion/sconce/icon.dmi'
	icon_state = "sconce"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	light_system = STATIC_LIGHT
	light_on = TRUE
	light_power = 0.6
	light_range = 4
	light_color = COLOR_VERY_SOFT_YELLOW

/obj/structure/mansion/sconce/fixednorth
	dir = NORTH
	pixel_y = 2

/obj/structure/mansion/sconce/off
	icon_state = "sconceextinguished"
	light_on = FALSE

/obj/structure/mansion/sconce/double
	icon_state = "doublesconce"
	light_range = 6

/obj/structure/mansion/sconce/double/off
	icon_state = "doublesconceextinguished"
	light_on = FALSE
