/obj/structure/reagent_water_basin
	name = "water basin"
	desc = "A basin full of water, ready to quench the hot metal."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_structures.dmi'
	icon_state = "water_basin"
	anchored = TRUE
	density = TRUE

	/// Tracks if you can fish from this basin
	var/datum/component/fishing_spot/fishable

/obj/structure/reagent_water_basin/Initialize(mapload)
	. = ..()

/obj/structure/reagent_water_basin/Destroy()
	QDEL_NULL(fishable)
	return ..()

/obj/structure/reagent_water_basin/examine(mob/user)
	. = ..()
	if(!fishable)
		. += span_notice("[src] can be upgraded through a bluespace crystal or a journeyman smithy!")

	else
		. += span_notice("[src] looks to be a bottomless basin of water... You can even see fish swimming around down there!")

/obj/structure/reagent_water_basin/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/smithing_skill = user.mind.get_skill_level(/datum/skill/smithing)
	if(smithing_skill < SKILL_LEVEL_JOURNEYMAN || fishable)
		return

	balloon_alert(user, "the water deepens!")
	fishable = AddComponent(/datum/component/fishing_spot, /datum/fish_source/water_basin)

/obj/structure/reagent_water_basin/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_obj = attacking_item
		if(!glass_obj.use(1))
			return

		new /obj/item/stack/clay(get_turf(src))
		user.mind.adjust_experience(/datum/skill/production, 1)
		return

	if(istype(attacking_item, /obj/item/stack/ore/bluespace_crystal))
		if(fishable)
			return
		var/obj/item/stack/ore/bluespace_crystal/bs_crystal = attacking_item

		if(!bs_crystal.use(1))
			return

		balloon_alert(user, "the water deepens!")
		fishable = AddComponent(/datum/component/fishing_spot, /datum/fish_source/water_basin)
		return

	return ..()

/obj/structure/reagent_water_basin/wrench_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return

	deconstruct(disassembled = TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/reagent_water_basin/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)

/obj/structure/reagent_water_basin/tong_act(mob/living/user, obj/item/tool)
	var/obj/item/forging/incomplete/search_incomplete = locate(/obj/item/forging/incomplete) in tool.contents
	if(!search_incomplete)
		return ITEM_INTERACT_SUCCESS

	playsound(src, 'modular_doppler/reagent_forging/sound/hot_hiss.ogg', 50, TRUE)

	if(search_incomplete?.times_hit < search_incomplete.average_hits)
		to_chat(user, span_warning("You cool down [search_incomplete], but it wasn't ready yet."))
		COOLDOWN_RESET(search_incomplete, heating_remainder)
		return ITEM_INTERACT_SUCCESS

	if(search_incomplete?.times_hit >= search_incomplete.average_hits)
		to_chat(user, span_notice("You cool down [search_incomplete] and it's ready."))
		user.mind.adjust_experience(/datum/skill/smithing, 10) //using the water basin on a ready item gives decent experience.

		var/obj/spawned_obj = new search_incomplete.spawn_item(get_turf(src))
		if(search_incomplete.custom_materials)
			spawned_obj.set_custom_materials(search_incomplete.custom_materials, 1) //lets set its material

		qdel(search_incomplete)
		tool.icon_state = "tong_empty"
	return ITEM_INTERACT_SUCCESS

/// Fishing source for fishing out of basins that have been upgraded, contains saltwater fish (lizard fish fall under this too!)
/datum/fish_source/water_basin
	catalog_description = "Bottomless Water Basins"
	fish_table = list(
		/obj/item/fish/clownfish = 15,
		/obj/item/fish/pufferfish = 10,
		/obj/item/fish/cardinal = 15,
		/obj/item/fish/greenchromis = 15,
		/obj/item/fish/lanternfish = 5,
		/obj/item/fish/dwarf_moonfish = 15,
		/obj/item/fish/gunner_jellyfish = 15,
		/obj/item/fish/needlefish = 10,
		/obj/item/fish/armorfish = 10,
		/obj/effect/spawner/random/maintenance = 10,
		/obj/effect/spawner/random/trash/garbage = 15,
	)
