/obj/effect/decal/cleanable/crayon/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null)
	. = ..()
	if(type == "poseur tag")
		var/datum/team/gang/gang = pick(subtypesof(/datum/team/gang))
		var/gangname = initial(gang.name)
		icon = 'icons/effects/crayondecal.dmi'
		icon_state = "[gangname]"
		type = null

/obj/effect/decal/cleanable/crayon/gang
	icon = 'icons/effects/crayondecal.dmi'
	layer = ABOVE_NORMAL_TURF_LAYER //Harder to hide
	plane = GAME_PLANE
	do_icon_rotate = FALSE //These are designed to always face south, so no rotation please.
	var/datum/team/gang/gang
	var/datum/mind/tagger

/obj/effect/decal/cleanable/crayon/gang/Initialize(mapload, datum/team/gang/G, e_name = "gang tag", rotation = 0,  mob/user)
	if(!G)
		return INITIALIZE_HINT_QDEL
	gang = G
	var/newcolor = G.color
	var/area/territory = get_area(src)
	icon_state = G.name
	G.new_territories |= list(territory.type = territory.name)
	if(user.mind)
		tagger = user.mind
		LAZYADD(G.tags_by_mind[tagger], src)
	//If this isn't tagged by a specific gangster there's no bonus income.
	.=..(mapload, newcolor, icon_state, e_name, rotation)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	if(gang)
		if(tagger)
			LAZYREMOVE(gang.tags_by_mind[tagger], src)
		var/area/territory = get_area(src)
		gang.territories -= territory.type
		gang.new_territories -= territory.type
		gang.lost_territories |= list(territory.type = territory.name)
		gang = null
	return ..()

/obj/effect/decal/cleanable/crayon/NeverShouldHaveComeHere(turf/T)
	return isspaceturf(T) || islava(T) || istype(T, /turf/open/water) || ischasm(T)
