/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "Graffiti. Damn kids."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	gender = NEUTER
	plane = GAME_PLANE //makes the graffiti visible over a wall.
	mergeable_decal = FALSE
	flags_1 = ALLOW_DARK_PAINTS_1
	var/do_icon_rotate = TRUE
	var/rotation = 0
	var/paint_colour = COLOR_WHITE

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null)
	. = ..()
	if(e_name)
		name = e_name
	desc = "A [name] vandalizing the station."
	if(alt_icon)
		icon = alt_icon
	if(type)
		icon_state = type
	if(graf_rot)
		rotation = graf_rot
	if(rotation && do_icon_rotate)
		var/matrix/M = matrix()
		M.Turn(rotation)
		src.transform = M
	if(main)
		paint_colour = main
	add_atom_colour(paint_colour, FIXED_COLOUR_PRIORITY)
	RegisterSignal(src, COMSIG_OBJ_PAINTED, PROC_REF(on_painted))

/obj/effect/decal/cleanable/crayon/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf)

/obj/effect/decal/cleanable/crayon/proc/on_painted(datum/source, mob/user, obj/item/toy/crayon/spraycan/spraycan, is_dark_color)
	SIGNAL_HANDLER
	var/cost = spraycan.all_drawables[icon_state] || CRAYON_COST_DEFAULT
	if (HAS_TRAIT(user, TRAIT_TAGGER))
		cost *= 0.5
	spraycan.use_charges(user, cost, requires_full = FALSE)
	return DONT_USE_SPRAYCAN_CHARGES

///Common crayon decals in map.
/obj/effect/decal/cleanable/crayon/rune4
	icon_state = "rune4"
	paint_colour = COLOR_CRAYON_RED

/obj/effect/decal/cleanable/crayon/rune2
	icon_state = "rune2"

/obj/effect/decal/cleanable/crayon/x
	icon_state = "x"
	name = "graffiti"
	paint_colour = COLOR_CRAYON_ORANGE

/obj/effect/decal/cleanable/crayon/l
	icon_state = "l"

/obj/effect/decal/cleanable/crayon/i
	icon_state = "i"

/obj/effect/decal/cleanable/crayon/e
	icon_state = "e"

/obj/effect/decal/cleanable/crayon/i/orange
	name = "graffiti"
	paint_colour = COLOR_CRAYON_ORANGE
