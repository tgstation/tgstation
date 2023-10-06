/obj/item/trench_ladder_kit
	name = "sea ladder"
	desc = "A deployable sea ladder that will allow you to descend to and ascend from the trench. Needs to be placed over a catwalk covered trench hole."

	icon = 'goon/icons/obj/fluid.dmi'
	icon_state = "ladder_off"

/obj/structure/trench_ladder
	name = "sea ladder"
	desc = "A deployable sea ladder that will allow you to descend to and ascend from the trench."

	icon = 'goon/icons/obj/fluid.dmi'
	icon_state = "ladder_on"

	var/obj/structure/trench_ladder/linked_ladder
	var/obj/item/trench_ladder_kit/real_item

/obj/structure/trench_ladder/Initialize(mapload)
	. = ..()
	if(src.z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/turf/turf = locate(src.x, src.y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1])
		if(isclosedturf(turf))
			turf.TerraformTurf(/turf/open/floor/plating/ocean/dark/rock/heavy, /turf/open/floor/plating/ocean/dark/rock/heavy,  flags = CHANGETURF_INHERIT_AIR)
		var/obj/structure/trench_ladder/search = locate(/obj/structure/trench_ladder) in turf.contents
		if(search)
			search.linked_ladder = src
			if(search.real_item)
				real_item = search.real_item
			else
				real_item = new(src)
				search.real_item = real_item
		else
			real_item = new(src)
			var/obj/structure/trench_ladder/ladder = new /obj/structure/trench_ladder(turf)
			ladder.linked_ladder = src
			ladder.real_item = real_item

	else if(src.z in SSmapping.levels_by_trait(ZTRAIT_MINING))
		var/turf/turf = locate(src.x, src.y, SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
		var/obj/structure/trench_ladder/search = locate(/obj/structure/trench_ladder) in turf.contents
		if(search)
			search.linked_ladder = src
			if(search.real_item)
				real_item = search.real_item
			else
				real_item = new(src)
				search.real_item = real_item
		else
			real_item = new(src)
			var/obj/structure/trench_ladder/ladder = new /obj/structure/trench_ladder(turf)
			ladder.linked_ladder = src
			ladder.real_item = real_item

/obj/structure/trench_ladder/Destroy()
	. = ..()
	if(linked_ladder)
		linked_ladder = null
	if(real_item)
		real_item = null

/obj/structure/trench_ladder/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!linked_ladder)
		return

	to_chat(user, span_notice("You begin climbing down [src]..."))
	if(do_after(user, 30, target = src))
		user.Move(get_turf(linked_ladder))

/obj/structure/trench_ladder/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	to_chat(user, span_notice("You begin dismantling [src]..."))
	if(do_after(user, 30, target = src))
		linked_ladder.real_item = null
		qdel(linked_ladder)
		real_item.Move(get_turf(src))
		real_item = null
		linked_ladder = null
		qdel(src)
