/obj/structure/mansion/street_lamp
	name = "outside lamp"
	desc = "A lamp mounted on a pole."
	icon = 'modular_event/spooky_mansion/street_lamp/icon.dmi'
	icon_state = "streetlamp"
	anchored = TRUE
	density = TRUE
	light_system = STATIC_LIGHT
	light_power = 0.5
	light_range = 8
	light_color = COLOR_VERY_SOFT_YELLOW
	layer = ABOVE_ALL_MOB_LAYER
	pixel_y = 16

/obj/structure/mansion/street_lamp/Initialize(mapload)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(2, 2)
	transform = matrix_transformation
