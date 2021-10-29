/obj/structure/reagent_water_basin
	name = "water basin"
	desc = "A basin full of water, ready to quench the hot metal."
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_structures.dmi'
	icon_state = "water_basin"
	anchored = TRUE
	density = TRUE

/obj/structure/reagent_water_basin/Initialize()
	. = ..()
	if(is_mining_level(z))
		icon_state = "primitive_water_basin"

/obj/structure/reagent_water_basin/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/forging/tongs))
		var/obj/item/forging/incomplete/searchIncomplete = locate(/obj/item/forging/incomplete) in I.contents
		if(searchIncomplete?.times_hit < searchIncomplete.average_hits)
			to_chat(user, span_warning("You cool down the metal-- it wasn't ready yet."))
			searchIncomplete.heat_world_compare = 0
			playsound(src, 'modular_skyrat/modules/reagent_forging/sound/hot_hiss.ogg', 50, TRUE)
			return
		if(searchIncomplete?.times_hit >= searchIncomplete.average_hits)
			to_chat(user, span_notice("You cool down the metal-- it is ready."))
			playsound(src, 'modular_skyrat/modules/reagent_forging/sound/hot_hiss.ogg', 50, TRUE)
			var/obj/item/forging/complete/spawnItem = searchIncomplete.spawn_item
			new spawnItem(get_turf(src))
			qdel(searchIncomplete)
			I.icon_state = "tong_empty"
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		for(var/i in 1 to 5)
			new /obj/item/stack/sheet/mineral/wood(get_turf(src))
		qdel(src)
		return
	if(istype(I, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_obj = I
		if(!glass_obj.use(1))
			return
		new /obj/item/ceramic/clay(get_turf(src))
		return
	if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		var/check_fishable = GetComponent(/datum/component/fishing)
		if(check_fishable)
			return
		var/obj/item/stack/ore/bluespace_crystal/bs_crystal = I
		if(!bs_crystal.use(1))
			return
		to_chat(user, span_notice("You connect [src], through bluespace, to a distant ocean."))
		AddComponent(/datum/component/fishing, set_loot = GLOB.fishing_weights, allow_fishes = TRUE)
	return ..()
