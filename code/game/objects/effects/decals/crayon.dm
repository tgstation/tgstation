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
	if(type == "poseur tag")
		type = pick(GLOB.gang_name_pool)

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
	var/datum/mind/user_mind
	var/area/territory

/obj/effect/decal/cleanable/crayon/gang/Initialize(mapload, var/datum/gang/G, var/e_name = "gang tag", var/rotation = 0,  var/mob/user)
	if(!type || !G)
		qdel(src)
	user_mind = user.mind
	territory = get_area(src)
	gang = G
	var/newcolor = G.color_hex
	icon_state = G.name
	G.territory_new |= list(territory.type = territory.name)
	//If this isn't tagged by a specific gangster there's no bonus income.
	set_mind_owner(user_mind)
	..(mapload, newcolor, icon_state, e_name, rotation)

/obj/effect/decal/cleanable/crayon/gang/proc/set_mind_owner(datum/mind/mind)
	if(istype(user_mind) && istype(gang) && islist(gang.tags_by_mind[user_mind]))	//Clear us out of old ownership
		gang.tags_by_mind[user_mind] -= src
	if(istype(mind))
		if(!islist(gang.tags_by_mind[mind]))
			gang.tags_by_mind[mind] = list()
		gang.tags_by_mind[mind] += src
		user_mind = mind

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	if(gang)
		gang.territory -= territory.type
		set_mind_owner(null)
		gang.territory_new -= territory.type
		gang.territory_lost |= list(territory.type = territory.name)
	return ..()
