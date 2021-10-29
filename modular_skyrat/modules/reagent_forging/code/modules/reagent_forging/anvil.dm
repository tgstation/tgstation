/obj/structure/reagent_anvil
	name = "anvil"
	desc = "An object with the intent to hammer metal against. One of the most important parts for forging an item."
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_structures.dmi'
	icon_state = "anvil_empty"

	anchored = TRUE
	density = TRUE
	var/primitive = FALSE

/obj/structure/reagent_anvil/Initialize()
	. = ..()
	if(is_mining_level(z))
		primitive = TRUE
		icon_state = "primitive_anvil_empty"

/obj/structure/reagent_anvil/attackby(obj/item/I, mob/living/user, params)
	var/obj/item/forging/incomplete/searchIncompleteSrc = locate(/obj/item/forging/incomplete) in contents
	if(istype(I, /obj/item/forging/hammer) && searchIncompleteSrc)
		playsound(src, 'modular_skyrat/modules/reagent_forging/sound/forge.ogg', 50, TRUE)
		if(searchIncompleteSrc.heat_world_compare <= world.time)
			to_chat(user, span_warning("You mess up, the metal was too cool!"))
			searchIncompleteSrc.times_hit -= 3
			return
		if(searchIncompleteSrc.world_compare <= world.time)
			searchIncompleteSrc.world_compare = world.time + searchIncompleteSrc.average_wait
			searchIncompleteSrc.times_hit++
			to_chat(user, span_notice("You strike the metal-- good hit."))
			if(searchIncompleteSrc.times_hit >= searchIncompleteSrc.average_hits)
				to_chat(user, span_notice("The metal is sounding ready."))
			return
		searchIncompleteSrc.times_hit -= 3
		to_chat(user, span_warning("You strike the metal-- bad hit."))
		if(searchIncompleteSrc.times_hit <= -(searchIncompleteSrc.average_hits))
			to_chat(user, span_warning("The hits were too inconsistent-- the metal breaks!"))
			if(!primitive)
				icon_state = "anvil_empty"
			else
				icon_state = "primitive_anvil_empty"
			qdel(searchIncompleteSrc)
		return
	if(istype(I, /obj/item/forging/tongs))
		var/obj/item/forging/incomplete/searchIncompleteItem = locate(/obj/item/forging/incomplete) in I.contents
		if(searchIncompleteSrc && !searchIncompleteItem)
			searchIncompleteSrc.forceMove(I)
			if(!primitive)
				icon_state = "anvil_empty"
			else
				icon_state = "primitive_anvil_empty"
			I.icon_state = "tong_full"
			return
		if(!searchIncompleteSrc && searchIncompleteItem)
			searchIncompleteItem.forceMove(src)
			if(!primitive)
				icon_state = "anvil_full"
			else
				icon_state = "primitive_anvil_full"
			I.icon_state = "tong_empty"
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		new /obj/item/stack/sheet/iron/ten(get_turf(src))
		qdel(src)
		return
	return ..()
