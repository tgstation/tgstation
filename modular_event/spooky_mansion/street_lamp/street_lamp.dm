/obj/structure/mansion/street_lamp
	name = "outside lamp"
	desc = "A lamp mounted on a pole."
	icon = 'modular_event/spooky_mansion/street_lamp/icon.dmi'
	icon_state = "streetlamp"
	anchored = TRUE
	light_system = STATIC_LIGHT
	light_on = TRUE
	light_power = 0.6
	light_range = 7
	light_color = COLOR_VERY_SOFT_YELLOW

/obj/structure/mansion/street_lamp/Initialize(mapload)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(2, 2)
	transform = matrix_transformation
