/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "Graffiti. Damn kids."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	gender = NEUTER
	var/do_icon_rotate = TRUE

/obj/effect/decal/cleanable/crayon/New(location, main = "#FFFFFF", var/type = "rune1", var/e_name = "rune", var/rotation = 0, var/alt_icon = null)
	..()
	loc = location

	name = e_name
	desc = "A [name] vandalizing the station."
	if(type == "poseur tag")
		type = pick(gang_name_pool)

	if(alt_icon)
		icon = alt_icon
	icon_state = type

	if(rotation && do_icon_rotate)
		var/matrix/M = matrix()
		M.Turn(rotation)
		src.transform = M

	add_atom_colour(main, FIXED_COLOUR_PRIORITY)


/obj/effect/decal/cleanable/crayon/gang
	layer = HIGH_OBJ_LAYER //Harder to hide
	do_icon_rotate = FALSE //These are designed to always face south, so no rotation please.
	var/datum/gang/gang

/obj/effect/decal/cleanable/crayon/gang/New(location, var/datum/gang/G, var/e_name = "gang tag", var/rotation = 0)
	if(!type || !G)
		qdel(src)

	var/area/territory = get_area(location)
	gang = G
	var/newcolor = G.color_hex
	icon_state = G.name
	G.territory_new |= list(territory.type = territory.name)

	..(location, newcolor, icon_state, e_name, rotation)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	var/area/territory = get_area(src)

	if(gang)
		gang.territory -= territory.type
		gang.territory_new -= territory.type
		gang.territory_lost |= list(territory.type = territory.name)
	return ..()
