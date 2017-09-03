/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "Graffiti. Damn kids."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	gender = NEUTER
	var/do_icon_rotate = TRUE

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main = "#FFFFFF", var/type = "rune1", var/e_name = "rune", var/rotation = 0, var/alt_icon = null)
	..()

	name = e_name
	desc = "A [name] vandalizing the station."
	if(alt_icon)
		icon = alt_icon
	icon_state = type

	if(rotation && do_icon_rotate)
		var/matrix/M = matrix()
		M.Turn(rotation)
		src.transform = M

	add_atom_colour(main, FIXED_COLOUR_PRIORITY)

