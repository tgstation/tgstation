/// Ratwood's seeds (code/modules/farming/seeds.dm, roguejobs/alchemist/herb_seeds.dm): every seed of GLOB.rogue_seed_grows grows
/// its crop, herb or sapling in soil. The seed rows hold the seeds of two kinds: those the porter brought are Rockhill items
/// (/obj/item/seeds/pear), those whose path TG already has are TG seed packs (/obj/item/seeds/wheat), which on medieval maps take
/// Ratwood's look here. Either kind shows the colour of its crop (Ratwood seed_color, new every round), and a farmer who knows
/// seeds can tell them apart on examine.
/datum/element/rogue_seed
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/rogue_seed/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/seed = target
	var/datum/plant_def/plant = GLOB.rogue_plant_defs[GLOB.rogue_seed_grows[seed.type]]
	if(plant)
		seed.color = plant.seed_color
	RegisterSignal(seed, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/element/rogue_seed/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	return ..()

/// Ratwood seeds examine(): who knows seeds can tell what these are.
/datum/element/rogue_seed/proc/on_examine(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/identity = GLOB.rogue_seed_identities[source.type]
	if(identity && rogue_knows_seeds(user, ispath(GLOB.rogue_seed_grows[source.type], /obj/structure/flora/roguegrass/herb)))
		examine_list += span_info("I can tell these are [identity]")

/// Seeds the porter brought, herb seeds among them, are Rockhill items.
/obj/item/rockhill/Initialize(mapload)
	. = ..()
	if(GLOB.rogue_seed_identities[type])
		AddElement(/datum/element/rogue_seed)

/// A TG seed pack that is a Ratwood seed on the Rockhill map looks like one: Ratwood's seed sprite and name, its crop's colour.
/obj/item/seeds/Initialize(mapload, nogenes = FALSE)
	. = ..()
	if(!GLOB.rogue_seed_identities[type] || !rogue_farming_enabled())
		return
	icon = 'modular_redtard/rockhill/icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"
	name = "seeds"
	desc = null
	AddElement(/datum/element/rogue_seed)

/// Ratwood's random seed packet becomes one of its crop seeds where it appears; TG's makes up a strange plant, which is what it
/// stays on modern maps.
/obj/item/seeds/random/Initialize(mapload)
	. = ..()
	if(!rogue_farming_enabled())
		return
	var/list/seeds = rogue_random_seeds()
	if(!length(seeds))
		return
	var/seed_type = pick(seeds)
	var/obj/item/seed = new seed_type(loc)
	seed.pixel_x += rand(-3, 3)
	return INITIALIZE_HINT_QDEL

/// Ratwood try_plant_seed() of every kind of seed: a crop seed plants its crop, a herb seed a seedling that blooms into the herb,
/// a tree or bush seed its sapling (a journeyman's work). FALSE when something already grows here or the seed cannot be sown.
/obj/structure/soil/proc/rogue_plant_seed(obj/item/seed, mob/living/user)
	var/grows = GLOB.rogue_seed_grows[seed.type]
	if(ispath(grows, /obj/structure/tree_sapling) || ispath(grows, /obj/structure/bush_sapling))
		if(!rogue_can_plant_sapling(user, grows, get_turf(src)))
			return FALSE
		if(plant || has_custom_growth())
			to_chat(user, span_warning("There is already something growing in \the [src]!"))
			return FALSE
		rogue_put_sapling(seed, user, grows, get_turf(src))
		return TRUE
	if(plant || has_custom_growth())
		to_chat(user, span_warning("There is already something planted in \the [src]!"))
		return FALSE
	if(ispath(grows, /obj/structure/flora/roguegrass/herb))
		to_chat(user, span_notice("I plant \the [seed] in \the [src]. I should check back later when it has grown."))
		var/obj/structure/soil_seedling/herb/seedling = new(get_turf(src))
		seedling.configure_seedling(src, seed.icon, seed.icon_state, grows, rogue_value("farm_herb_grow_time"))
		seedling.desc = "A small seedling bedded in a soil plot. It will need healthy soil to sprout."
		qdel(seed)
		return TRUE
	var/datum/plant_def/crop = GLOB.rogue_plant_defs[grows]
	if(!crop?.can_grow())
		to_chat(user, span_warning("I can't make out how to grow these."))
		return FALSE
	to_chat(user, span_notice("I plant \the [seed] in \the [src]."))
	insert_plant(crop)
	qdel(seed)
	return TRUE

/// Ratwood treesap and bush seed checks: a journeyman's work, one sapling of a kind on a tile.
/proc/rogue_can_plant_sapling(mob/living/user, sapling_type, turf/spot)
	var/kind = ispath(sapling_type, /obj/structure/tree_sapling) ? "tree" : "bush"
	if(user.rogue_learned_rank(ROGUE_FARMING_SKILL) < rogue_value("farm_skilled_rank"))
		to_chat(user, span_warning("I don't have the farming knowledge to tend a [kind] sapling."))
		return FALSE
	if(locate(ispath(sapling_type, /obj/structure/tree_sapling) ? /obj/structure/tree_sapling : /obj/structure/bush_sapling) in spot)
		to_chat(user, span_warning("There's already a[kind == "bush" ? " bush" : ""] sapling growing here."))
		return FALSE
	return TRUE

/// Ratwood plant_tree_sapling() and the bush seed's planting: the sapling stands in the soil and the seed is gone.
/proc/rogue_put_sapling(obj/item/seed, mob/living/user, sapling_type, turf/spot)
	new sapling_type(spot)
	if(ispath(sapling_type, /obj/structure/tree_sapling))
		to_chat(user, span_notice("I carefully plant the [ispath(sapling_type, /obj/structure/tree_sapling/pine) ? "pine " : ispath(sapling_type, /obj/structure/tree_sapling/sakura) ? "sakura " : "tree "]sapling and pat the soil down."))
	else
		to_chat(user, span_notice("I plant the bush seed and pat down the earth."))
	qdel(seed)

/// Ratwood seeds attack_turf(): seeds on the ground. With soil there they go into it; a tree or bush seed is planted in dirt or
/// grass, the soil heaped for it; a herb seed gets a mound in dirt and goes into it; a crop seed only gets its mound in dirt, by a
/// journeyman, and is sown with another click.
/turf/open/floor/rogue/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/grows = GLOB.rogue_seed_grows[tool.type]
	if(!grows || !isliving(user))
		return ..()
	var/obj/structure/soil/soil = locate() in src
	if(soil)
		soil.rogue_plant_seed(tool, user)
		return ITEM_INTERACT_SUCCESS
	if(ispath(grows, /obj/structure/tree_sapling) || ispath(grows, /obj/structure/bush_sapling))
		INVOKE_ASYNC(src, PROC_REF(rogue_plant_sapling_here), tool, user, grows)
		return ITEM_INTERACT_SUCCESS
	if(!istype(src, /turf/open/floor/rogue/dirt))
		return ..()
	if(ispath(grows, /datum/plant_def) && user.rogue_learned_rank(ROGUE_FARMING_SKILL) < rogue_value("farm_skilled_rank"))
		to_chat(user, span_notice("I don't know enough to work without a tool."))
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(rogue_heap_mound), tool, user, grows)
	return ITEM_INTERACT_SUCCESS

/// Ratwood seeds and herb seeds attack_turf() on dirt: heap a mound of soil; a herb seed goes straight into it.
/turf/open/floor/rogue/proc/rogue_heap_mound(obj/item/seed, mob/living/user, grows)
	to_chat(user, span_notice("I begin making a mound for the seeds..."))
	if(!do_after(user, user.rogue_farming_time(rogue_value("farm_mound_time")), target = src))
		return
	user.rogue_farming_fatigue(rogue_value("farm_mound_fatigue"))
	var/obj/structure/soil/soil = locate() in src
	if(!soil)
		soil = new(src)
	if(ispath(grows, /obj/structure/flora/roguegrass/herb) && !QDELETED(seed))
		soil.rogue_plant_seed(seed, user)

/// Ratwood treesap and bush seed attack_turf(): plant the sapling in dirt or grass (or soil), heaping its soil.
/turf/open/floor/rogue/proc/rogue_plant_sapling_here(obj/item/seed, mob/living/user, sapling_type)
	if(!rogue_can_plant_sapling(user, sapling_type, src))
		return
	if(!istype(src, /turf/open/floor/rogue/dirt) && !istype(src, /turf/open/floor/rogue/grass))
		to_chat(user, span_warning("I need to plant this in soil, on dirt, or on grass."))
		return
	var/tree = ispath(sapling_type, /obj/structure/tree_sapling)
	to_chat(user, span_notice(tree ? "I begin preparing the ground for the tree sapling..." : "I begin mounding up earth for the bush seed..."))
	if(!do_after(user, user.rogue_farming_time(tree ? rogue_value("farm_tree_plant_time") : rogue_value("farm_bush_plant_time")), target = src))
		return
	user.rogue_farming_fatigue(tree ? rogue_value("farm_tree_plant_fatigue") : rogue_value("farm_bush_plant_fatigue"))
	// Re-check after delay
	if(QDELETED(seed) || (locate(tree ? /obj/structure/tree_sapling : /obj/structure/bush_sapling) in src))
		return
	if(!(locate(/obj/structure/soil) in src))
		new /obj/structure/soil(src)
	rogue_put_sapling(seed, user, sapling_type, src)

/// Ratwood grown attackby() and examine(): produce with seeds in it gives them up when knocked about on the ground with something
/// blunt.
/obj/item/reagent_containers/food/snacks/grown/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/seed_type = GLOB.rogue_produce_seeds[type]
	if(!seed_type || !isturf(loc) || !isliving(user))
		return ..()
	var/datum/intent/intent = user.rogue_active_intent()
	if(intent?.blade_class != BCLASS_BLUNT || intent.noaa)
		return ..()
	rogue_drop_seeds(seed_type, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/food/snacks/grown/examine(mob/user)
	. = ..()
	if(GLOB.rogue_produce_seeds[type])
		. += span_smallnotice("Smash this with a blunt object to extract seeds from it.")

/// Ratwood's seed extraction from produce and pumpkins: rarely nothing comes of it; else a seed, often two, sometimes more. The
/// produce is gone either way.
/obj/item/proc/rogue_drop_seeds(seed_type, mob/living/user)
	var/turf/spot = get_turf(src)
	playsound(spot, ROGUE_SEED_EXTRACT_SOUND, 100, FALSE)
	if(prob(rogue_value("farm_seed_extract_fail")))
		user.visible_message(span_warning("[user] fails to extract the seeds."))
		qdel(src)
		return
	user.visible_message(span_info("[user] extracts the seeds."))
	new seed_type(spot)
	for(var/chance in list(rogue_value("farm_seed_extra_first"), rogue_value("farm_seed_extra_second"), rogue_value("farm_seed_extra_third")))
		if(prob(chance))
			new seed_type(spot)
	qdel(src)
