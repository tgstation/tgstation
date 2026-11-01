/// Ratwood's soil (code/modules/farming/soil.dm): a bed of tilled dirt that holds water, nutrition and weeds and grows one crop.
/// Water and nutrition seep away, weeds spread where there is both and drink them, a crop drinks water to stay healthy and eats
/// nutrition to grow, first to maturity, then one harvest at a time. Soil left with no water, no nutrition and no living crop
/// flattens back into dirt. It works on SSobj every 2 seconds (Ratwood SSprocessing every second) at Ratwood's rates, which are
/// per decisecond, and its look is redrawn only when one of the thresholds it shows is crossed. Soil cannot be broken (Ratwood
/// max_integrity 0), so a blow with a tool always reaches the farm work below.
/obj/structure/soil
	obj_flags = NONE
	resistance_flags = INDESTRUCTIBLE
	/// Amount of water in the soil. It keeps the crop and the weeds from losing health.
	var/water = 0
	/// Amount of weeds in the soil. The more of them, the more water and nutrition they eat.
	var/weeds = 0
	/// Amount of nutrition in the soil. The crop eats it to mature and to make produce; it also makes the weeds grow.
	var/nutrition = 0
	/// Crop health. At zero the crop is dead: it no longer grows nor makes produce and has to be uprooted.
	var/plant_health = ROGUE_SOIL_MAX_HEALTH
	/// The crop planted here, one of the shared definitions of GLOB.rogue_plant_defs.
	var/datum/plant_def/plant = null
	/// Deciseconds of growth so far.
	var/growth_time = 0
	/// Deciseconds of growth towards the next harvest so far.
	var/produce_time = 0
	/// Whether the crop has matured.
	var/matured = FALSE
	/// Whether the produce is ready for harvest.
	var/produce_ready = FALSE
	/// Whether the crop is dead.
	var/plant_dead = FALSE
	/// Deciseconds the soil stays tilled, which helps the crop grow.
	var/tilled_time = 0
	/// Deciseconds the soil stays blessed, which helps the crop grow and kills weeds.
	var/blessed_time = 0
	/// Deciseconds the soil stays pollinated, which helps the crop grow.
	var/pollination_time = 0
	/// Deciseconds left before soil with no water, no nutrition and no living crop flattens back into dirt.
	var/soil_decay_time = 0
	/// Deciseconds the special fertilizer keeps working: the crop grows faster, weeds die and nutrition stays topped up.
	var/fertilized_time = 0
	/// The thresholds its look was last drawn at (rogue_look_key()).
	var/rogue_look = -1

/obj/structure/soil/Initialize(mapload)
	. = ..()
	soil_decay_time = rogue_value("farm_soil_decay_time")
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)
	if(rogue_farming_enabled())
		START_PROCESSING(SSobj, src)
	rogue_refresh_look()

/obj/structure/soil/Destroy()
	STOP_PROCESSING(SSobj, src)
	plant = null
	return ..()

/obj/structure/soil/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(isliving(arrived))
		on_stepped(arrived)

/// Ratwood on_stepped(): walking across a crop tramples it, running more; sneaking spares it. Beasts walk.
/obj/structure/soil/proc/on_stepped(mob/living/stepper)
	if(!plant)
		return
	var/mob/living/carbon/human/walker = stepper
	if(istype(walker) && walker.rogue_sneaking)
		return
	if(istype(walker) && walker.move_intent == MOVE_INTENT_RUN)
		adjust_plant_health(-rogue_value("farm_trample_run"))
	else
		adjust_plant_health(-rogue_value("farm_trample_walk"))
	playsound(src, pick(ROGUE_PLANTCROSS_SOUNDS), 100, FALSE)
	rogue_refresh_look()

/obj/structure/soil/proc/user_harvests(mob/living/user)
	if(!produce_ready)
		return
	user.rogue_farming_fatigue(rogue_value("farm_harvest_fatigue"))
	user.rogue_farming_experience(rogue_value("farm_harvest_xp"))
	var/rank = user.rogue_learned_rank(ROGUE_FARMING_SKILL)
	var/rank_chance = rank * rogue_value("farm_harvest_rank_chance")
	if(prob(rogue_value("farm_ruin_chance") - rank_chance))
		ruin_produce()
		to_chat(user, span_warning("I ruin the produce..."))
		return
	var/feedback = "I harvest the produce."
	var/modifier = 0
	if(prob(rogue_value("farm_ruin_some_chance") - rank_chance))
		feedback = "I harvest the produce, ruining a little."
		modifier -= 1
	if(prob(rogue_value("farm_extra_produce_chance") + rank_chance))
		feedback = "I harvest the produce well."
		modifier += 1
	to_chat(user, span_notice(feedback))
	yield_produce(modifier, rank >= ROGUE_RANK_LEGENDARY)
	// Dendor patrons earn Druidic Trickery experience per successful harvest.
	var/mob/living/carbon/human/farmer = user
	if(istype(farmer) && istype(farmer.rogue_patron, /datum/patron/divine/dendor))
		farmer.rogue_craft_experience(/datum/attribute/skill/magic/druidic, rogue_value("farm_dendor_harvest_xp"))
	rogue_refresh_look()

/obj/structure/soil/proc/try_handle_harvest(obj/item/attacking_item, mob/living/user)
	if(!istype(attacking_item, /obj/item/rogueweapon/sickle))
		return FALSE
	if(!plant || !produce_ready)
		to_chat(user, span_warning("There is nothing to harvest!"))
		return TRUE
	user_harvests(user)
	playsound(src, ROGUE_SEED_SOUND, 100, FALSE)
	return TRUE

/obj/structure/soil/proc/try_handle_seed_planting(obj/item/attacking_item, mob/living/user)
	if(!GLOB.rogue_seed_grows[attacking_item.type])
		return FALSE
	rogue_plant_seed(attacking_item, user)
	return TRUE

/// Ratwood has_custom_growth(): a sapling or a seedling shares this soil, so no crop goes in.
/obj/structure/soil/proc/has_custom_growth()
	var/turf/here = get_turf(src)
	if(!here)
		return FALSE
	return (locate(/obj/structure/soil_seedling) in here) || (locate(/obj/structure/tree_sapling) in here) || (locate(/obj/structure/bush_sapling) in here)

/obj/structure/soil/proc/try_handle_uprooting(obj/item/attacking_item, mob/living/user)
	if(!istype(attacking_item, /obj/item/rogueweapon/shovel))
		return FALSE
	to_chat(user, span_notice("I begin to uproot the crop..."))
	playsound(src, ROGUE_DIG_SOUND, 100, TRUE)
	if(do_after(user, user.rogue_farming_time(rogue_value("farm_uproot_time")), target = src))
		to_chat(user, span_notice("I uproot the crop."))
		playsound(src, ROGUE_DIG_SOUND, 100, TRUE)
		uproot()
	return TRUE

/obj/structure/soil/proc/try_handle_tilling(obj/item/attacking_item, mob/living/user)
	if(!istype(attacking_item, /obj/item/rogueweapon/hoe))
		return FALSE
	var/work_time = rogue_value("farm_soil_till_time")
	if(user.rogue_learned_rank(ROGUE_FARMING_SKILL) >= ROGUE_RANK_LEGENDARY)
		work_time = rogue_value("farm_soil_till_legendary_time")
	to_chat(user, span_notice("I begin to till the soil..."))
	playsound(src, ROGUE_DIG_SOUND, 100, TRUE)
	if(do_after(user, user.rogue_farming_time(work_time), target = src))
		to_chat(user, span_notice("I till the soil."))
		playsound(src, ROGUE_DIG_SOUND, 100, TRUE)
		user_till_soil(user)
	return TRUE

/// Ratwood try_handle_watering(): an open vessel waters the soil with water, holy water, blessed water or dirty water, in that
/// order, each unit worth several of the soil's water.
/obj/structure/soil/proc/try_handle_watering(obj/item/attacking_item, mob/living/user)
	if(!istype(attacking_item, /obj/item/reagent_containers) || !attacking_item.reagents)
		return FALSE
	var/target_water = ROGUE_SOIL_MAX_WATER - water
	if(target_water <= 0)
		to_chat(user, span_warning("The soil is already wet!"))
		return TRUE
	var/per_unit = rogue_value("farm_water_per_unit")
	var/units_needed = CEILING(target_water / per_unit, 1)
	var/total_units = 0
	for(var/water_type in list(/datum/reagent/water, /datum/reagent/water/holywater, /datum/reagent/water/blessed, /datum/reagent/water/gross))
		var/taken = min(attacking_item.reagents.get_reagent_amount(water_type), units_needed - total_units)
		if(taken <= 0)
			continue
		attacking_item.reagents.remove_reagent(water_type, taken)
		total_units += taken
	if(total_units <= 0)
		to_chat(user, span_warning("There's no water in \the [attacking_item]!"))
		return TRUE
	playsound(user, pick('modular_redtard/survival/sound/waterwash1.ogg', 'modular_redtard/survival/sound/waterwash2.ogg'), 100, FALSE)
	to_chat(user, span_notice("I water the soil."))
	adjust_water(min(target_water, total_units * per_unit))
	rogue_refresh_look()
	return TRUE

/// Ratwood try_handle_fertilizing(): ash, manure and compost feed the soil, the special fertilizer works in it for a long while.
/obj/structure/soil/proc/try_handle_fertilizing(obj/item/attacking_item, mob/living/user)
	var/fertilize_amount = 0
	if(istype(attacking_item, /obj/item/ash))
		fertilize_amount = rogue_value("farm_ash_nutrition")
	else if(istype(attacking_item, /obj/item/natural/poo))
		fertilize_amount = rogue_value("farm_manure_nutrition")
	else if(istype(attacking_item, /obj/item/compost))
		fertilize_amount = rogue_value("farm_compost_nutrition")
	else if(istype(attacking_item, /obj/item/fertilizer))
		to_chat(user, span_notice("You mix the fertilizer into the soil..."))
		fertilize_soil()
		qdel(attacking_item)
		rogue_refresh_look()
		return TRUE
	if(fertilize_amount <= 0)
		return FALSE
	if(nutrition >= ROGUE_SOIL_MAX_NUTRITION * rogue_value("farm_full_nutrition_share"))
		to_chat(user, span_warning("The soil is already fertilized!"))
		return TRUE
	to_chat(user, span_notice("I fertilize the soil."))
	adjust_nutrition(fertilize_amount)
	qdel(attacking_item)
	rogue_refresh_look()
	return TRUE

/// Ratwood try_handle_deweed(): weeds come out by hand, slowly, or at once with a hoe.
/obj/structure/soil/proc/try_handle_deweed(obj/item/attacking_item, mob/living/user)
	if(weeds < ROGUE_SOIL_MAX_WEEDS * rogue_value("farm_weeds_some"))
		return FALSE
	if(isnull(attacking_item))
		to_chat(user, span_notice("I begin ripping out the weeds with my hands..."))
		if(do_after(user, user.rogue_farming_time(rogue_value("farm_deweed_time")), target = src))
			user.rogue_farming_fatigue(rogue_value("farm_deweed_hand_fatigue"))
			to_chat(user, span_notice("I rip out the weeds."))
			deweed()
		return TRUE
	if(istype(attacking_item, /obj/item/rogueweapon/hoe))
		user.rogue_farming_fatigue(rogue_value("farm_work_fatigue"))
		to_chat(user, span_notice("I rip out the weeds with the [attacking_item]"))
		deweed()
		return TRUE
	return FALSE

/// Ratwood try_handle_flatten(): a shovel flattens soil with nothing growing in it back into dirt.
/obj/structure/soil/proc/try_handle_flatten(obj/item/attacking_item, mob/living/user)
	if(plant || !istype(attacking_item, /obj/item/rogueweapon/shovel))
		return FALSE
	to_chat(user, span_notice("I begin flattening the soil with \the [attacking_item]..."))
	playsound(src, ROGUE_DIG_SOUND, 100, TRUE)
	if(do_after(user, user.rogue_farming_time(rogue_value("farm_flatten_time")), target = src) && !plant)
		user.rogue_farming_fatigue(rogue_value("farm_work_fatigue"))
		playsound(src, ROGUE_DIG_SOUND, 100, TRUE)
		to_chat(user, span_notice("I flatten the soil."))
		decay_soil()
	return TRUE

/// Ratwood attack_hand(): pick a ripe crop, or pull out a dead one.
/obj/structure/soil/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(plant && produce_ready)
		INVOKE_ASYNC(src, PROC_REF(hand_harvest), user)
		return TRUE
	if(plant && plant_dead)
		INVOKE_ASYNC(src, PROC_REF(remove_dead_crop), user)
		return TRUE

/obj/structure/soil/proc/hand_harvest(mob/living/user)
	to_chat(user, span_notice("I begin collecting the produce..."))
	if(do_after(user, user.rogue_farming_time(rogue_value("farm_harvest_time")), target = src))
		playsound(src, ROGUE_SEED_SOUND, 100, FALSE)
		user_harvests(user)

/obj/structure/soil/proc/remove_dead_crop(mob/living/user)
	to_chat(user, span_notice("I begin to remove the dead crop..."))
	if(!do_after(user, user.rogue_farming_time(rogue_value("farm_remove_dead_time")), target = src) || !plant || !plant_dead)
		return
	user.rogue_farming_fatigue(rogue_value("farm_work_fatigue"))
	to_chat(user, span_notice("I remove the crop."))
	playsound(src, ROGUE_SEED_SOUND, 100, FALSE)
	uproot()

/// Ratwood attack_right() with an empty hand: rip the weeds out.
/obj/structure/soil/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !isliving(user))
		return
	if(weeds < ROGUE_SOIL_MAX_WEEDS * rogue_value("farm_weeds_some"))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	INVOKE_ASYNC(src, PROC_REF(try_handle_deweed), null, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Ratwood attack_right() with a tool: a hoe rips the weeds out, a shovel flattens empty soil.
/obj/structure/soil/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	if(try_handle_deweed(tool, user) || try_handle_flatten(tool, user))
		user.changeNext_move(CLICK_CD_MELEE)
		return ITEM_INTERACT_SUCCESS
	return ..()

/// Ratwood attackby(): sow, uproot, till, water, fertilize or harvest, the first that fits the tool.
/obj/structure/soil/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	if(try_handle_seed_planting(tool, user) || try_handle_uprooting(tool, user) || try_handle_tilling(tool, user) \
		|| try_handle_watering(tool, user) || try_handle_fertilizing(tool, user) || try_handle_harvest(tool, user))
		user.changeNext_move(CLICK_CD_MELEE)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/structure/soil/proc/deweed()
	if(weeds >= ROGUE_SOIL_MAX_WEEDS * rogue_value("farm_weeds_some"))
		playsound(src, pick(ROGUE_PLANTCROSS_SOUNDS), 100, FALSE)
	adjust_weeds(-ROGUE_SOIL_MAX_WEEDS)
	rogue_refresh_look()

/obj/structure/soil/proc/user_till_soil(mob/living/user)
	user.rogue_farming_fatigue(rogue_value("farm_work_fatigue"))
	till_soil(rogue_value("farm_till_time") * user.rogue_farming_effort())

/// Ratwood till_soil(): tilled soil grows faster for a while; tilling tramples the crop a little and roots out some weeds.
/obj/structure/soil/proc/till_soil(time)
	tilled_time = isnull(time) ? rogue_value("farm_till_time") : time
	adjust_plant_health(-rogue_value("farm_till_crop_damage"))
	adjust_weeds(-rogue_value("farm_till_weeds"))
	if(plant)
		playsound(src, pick(ROGUE_PLANTCROSS_SOUNDS), 100, FALSE)
	rogue_refresh_look()

/// Ratwood bless_soil(), for Dendor's Bless Crop: the soil is blessed for a while, a dead crop comes back to life, low water and
/// nutrition are topped up and the crop grows a little at once.
/obj/structure/soil/proc/bless_soil()
	blessed_time = rogue_value("farm_bless_time")
	// It's a miracle! Plant comes back to life when blessed by Dendor
	if(plant && plant_dead)
		plant_dead = FALSE
		plant_health = rogue_value("farm_bless_revive_health")
	// If low on nutrition or water, Dendor provides
	var/least = rogue_value("farm_bless_least_stock")
	if(nutrition < least)
		adjust_nutrition(least - nutrition)
	if(water < least)
		adjust_water(least - water)
	// And it grows a little!
	if(plant)
		add_growth(rogue_value("farm_bless_growth"))
	rogue_refresh_look()

/// Ratwood fertilize_soil(): the special fertilizer keeps working for a good while.
/obj/structure/soil/proc/fertilize_soil()
	fertilized_time = rogue_value("farm_fertilizer_time")

/// Ratwood's bees (apiary.dm finish_pollinating()): pollinated soil grows its crop faster for a while.
/obj/structure/soil/proc/pollinate()
	pollination_time = rogue_value("farm_pollination_time")

/obj/structure/soil/proc/adjust_water(adjust_amount)
	water = clamp(water + adjust_amount, 0, ROGUE_SOIL_MAX_WATER)

/obj/structure/soil/proc/adjust_nutrition(adjust_amount)
	nutrition = clamp(nutrition + adjust_amount, 0, ROGUE_SOIL_MAX_NUTRITION)

/obj/structure/soil/proc/adjust_weeds(adjust_amount)
	weeds = clamp(weeds + adjust_amount, 0, ROGUE_SOIL_MAX_WEEDS)

/obj/structure/soil/proc/adjust_plant_health(adjust_amount)
	if(!plant || plant_dead)
		return
	plant_health = clamp(plant_health + adjust_amount, 0, ROGUE_SOIL_MAX_HEALTH)
	if(plant_health <= 0)
		plant_dead = TRUE
		produce_ready = FALSE

/obj/structure/soil/process(seconds_per_tick)
	var/dt = seconds_per_tick * (1 SECONDS)
	process_weeds(dt)
	process_plant(dt)
	process_soil(dt)
	if(soil_decay_time <= 0)
		decay_soil()
		return PROCESS_KILL
	if(rogue_rain_falls_on(src))
		adjust_water(rogue_value("farm_rain_water") * seconds_per_tick)
	rogue_refresh_look()

/obj/structure/soil/proc/process_weeds(dt)
	var/rate = dt / (1 MINUTES)
	// Blessed soil will have the weeds die
	if(blessed_time > 0 || fertilized_time > 0)
		adjust_weeds(-rate * rogue_value("farm_weed_bless_decay"))
	if(plant?.weed_immune)
		// Weeds die if the plant is immune to them
		adjust_weeds(-rate * rogue_value("farm_weed_immune_decay"))
		return
	if(water <= 0)
		// Weeds die without water in soil
		adjust_weeds(-rate * rogue_value("farm_weed_decay"))
		return
	// Weeds eat water and nutrition to grow
	var/weed_factor = weeds / ROGUE_SOIL_MAX_WEEDS
	adjust_water(-rate * weed_factor * rogue_value("farm_weed_water_use"))
	adjust_nutrition(-rate * weed_factor * rogue_value("farm_weed_nutrition_use"))
	if(nutrition > 0)
		adjust_weeds(rate * rogue_value("farm_weed_growth"))

/obj/structure/soil/proc/process_plant(dt)
	if(!plant || plant_dead)
		return
	process_plant_nutrition(dt)
	process_plant_health(dt)

/obj/structure/soil/proc/process_plant_health(dt)
	var/rate = dt / (1 MINUTES)
	var/drain_rate = plant.water_drain_rate
	// Lots of weeds harm the plant
	if(weeds >= ROGUE_SOIL_MAX_WEEDS * rogue_value("farm_weeds_overgrown"))
		adjust_plant_health(-rate * rogue_value("farm_crop_weed_harm"))
	// Regenerate plant health if we dont drain water, or we have the water
	if(drain_rate <= 0 || water > 0)
		adjust_plant_health(rate * rogue_value("farm_crop_regrowth"))
	if(drain_rate > 0)
		// If we're dry and we want to drain water, we lose health
		if(water <= 0)
			adjust_plant_health(-rate * rogue_value("farm_crop_wilt"))
		else
			adjust_water(-dt * drain_rate)
	// Blessed plants heal!!
	if(blessed_time > 0)
		adjust_plant_health(rate * rogue_value("farm_crop_bless_heal"))

/// Ratwood get_natural_growth_bonuses(): the share of growth blessed soil adds. Ratwood's Living Light (a sanctified tree) and
/// Rune of Dendor add to it there; neither is in the port.
/obj/structure/soil/proc/get_natural_growth_bonus()
	var/blessed_bonus = blessed_time > 0 ? rogue_value("farm_blessed_growth_bonus") : 0
	return min(blessed_bonus, rogue_value("farm_growth_bonus_cap"))

/// Ratwood get_environmental_growth_multiplier(): how fast this soil grows things whatever grows in it (saplings and seedlings
/// too): tilled, fertilized, pollinated and blessed soil faster, weedy soil slower. Ratwood's god-given world traits (Dendor's
/// fertility, drought) are not in the port.
/obj/structure/soil/proc/get_environmental_growth_multiplier()
	var/multiplier = 1
	if(tilled_time > 0)
		multiplier *= rogue_value("farm_tilled_growth")
	if(fertilized_time > 0)
		multiplier *= rogue_value("farm_fertilized_growth")
	if(pollination_time > 0)
		multiplier *= rogue_value("farm_pollinated_growth")
	multiplier *= 1 + get_natural_growth_bonus()
	var/slowdown = rogue_value("farm_growth_slowdown")
	if(weeds >= ROGUE_SOIL_MAX_WEEDS * rogue_value("farm_weeds_overgrown"))
		multiplier *= slowdown
	if(weeds >= ROGUE_SOIL_MAX_WEEDS * rogue_value("farm_weeds_some"))
		multiplier *= slowdown
	return multiplier

/// Whether the crop grows at all now (Ratwood process_plant_nutrition()): alive, under the open sky unless it grows anywhere,
/// not waiting for its harvest, and with water if it drinks.
/obj/structure/soil/proc/can_crop_grow()
	if(!plant || plant_dead)
		return FALSE
	if(!plant.can_grow_underground && !rogue_under_open_sky(src))
		return FALSE
	if(matured && produce_ready)
		return FALSE
	return plant.water_drain_rate <= 0 || water > 0

/// Ratwood calculate_growth_multiplier(): how fast the crop grows now, 0 if it does not. A sickly crop grows slower.
/obj/structure/soil/proc/calculate_growth_multiplier()
	if(!can_crop_grow())
		return 0
	var/multiplier = get_environmental_growth_multiplier()
	var/slowdown = rogue_value("farm_growth_slowdown")
	if(plant_health <= ROGUE_SOIL_MAX_HEALTH * rogue_value("farm_crop_dying"))
		multiplier *= slowdown
	if(plant_health <= ROGUE_SOIL_MAX_HEALTH * rogue_value("farm_crop_sick"))
		multiplier *= slowdown
	return multiplier

/// Ratwood process_plant_nutrition(). Ratwood also works out how much less blessed, fertilized and pollinated soil is eaten,
/// but never uses it; neither does this.
/obj/structure/soil/proc/process_plant_nutrition(dt)
	var/growth_multiplier = calculate_growth_multiplier()
	if(growth_multiplier > 0)
		process_growth(growth_multiplier * dt)

/// Ratwood process_growth(): growth eats nutrition in step; with too little nutrition the crop grows only as far as it lasts.
/obj/structure/soil/proc/process_growth(target_growth_time)
	var/target_nutrition
	if(!matured)
		target_nutrition = (plant.maturation_nutrition / plant.maturation_time) * target_growth_time
	else
		target_nutrition = (plant.produce_nutrition / plant.produce_time) * target_growth_time
	if(target_nutrition <= 0)
		add_growth(target_growth_time)
		return
	var/possible_nutrition = min(target_nutrition, nutrition)
	adjust_nutrition(-possible_nutrition)
	add_growth(target_growth_time * possible_nutrition / target_nutrition)

/obj/structure/soil/proc/add_growth(added_growth)
	growth_time += added_growth
	if(!matured)
		if(growth_time >= plant.maturation_time)
			matured = TRUE
	else
		produce_time += added_growth
		if(produce_time >= plant.produce_time)
			produce_time -= plant.produce_time
			produce_ready = TRUE

/obj/structure/soil/proc/process_soil(dt)
	// If plant exists and is not dead, nutriment or water is not zero, reset the decay timer
	if(nutrition > 0 || water > 0 || (plant && plant_health > 0))
		soil_decay_time = rogue_value("farm_soil_decay_time")
	else
		// Otherwise, "decay" the soil
		soil_decay_time = max(soil_decay_time - dt, 0)
	var/rate = dt / (1 MINUTES)
	adjust_water(-rate * rogue_value("farm_soil_water_decay"))
	adjust_nutrition(-rate * rogue_value("farm_soil_nutrition_decay") * (blessed_time > 0 ? rogue_value("farm_blessed_nutrition_decay") : 1))
	// Ratwood sets the nutrition of fertilized soil to 100 and never counts the fertilizer down; here it keeps the soil from
	// falling below and runs out.
	if(fertilized_time > 0)
		nutrition = max(nutrition, rogue_value("farm_fertilizer_nutrition"))
		fertilized_time = max(fertilized_time - dt, 0)
	tilled_time = max(tilled_time - dt, 0)
	blessed_time = max(blessed_time - dt, 0)
	pollination_time = max(pollination_time - dt, 0)

/obj/structure/soil/proc/decay_soil()
	uproot()
	qdel(src)

/obj/structure/soil/proc/uproot()
	if(!plant)
		return
	adjust_weeds(-ROGUE_SOIL_MAX_WEEDS)
	yield_uproot_loot()
	ruin_produce()
	plant = null
	rogue_refresh_look()

/// Spawns uproot loot, such as a log from an apple tree when removing the tree
/obj/structure/soil/proc/yield_uproot_loot()
	if(!matured || !length(plant.uproot_loot))
		return
	for(var/loot_type in plant.uproot_loot)
		var/count = plant.uproot_loot[loot_type]
		for(var/i in 1 to (isnum(count) ? count : 1))
			new loot_type(loc)

/obj/structure/soil/proc/ruin_produce()
	produce_ready = FALSE
	rogue_refresh_look()

/// Yields produce on its tile if it's ready for harvest. A legendary farmer's annual crop starts over instead of coming out.
/obj/structure/soil/proc/yield_produce(modifier = 0, is_legendary = FALSE)
	if(!produce_ready || !ispath(plant.produce_type))
		return
	var/spawn_amount = max(rand(plant.produce_amount_min, plant.produce_amount_max) + modifier, 1)
	for(var/i in 1 to spawn_amount)
		new plant.produce_type(loc)
	produce_ready = FALSE
	if(!plant.perennial)
		if(is_legendary)
			growth_time = 0
			matured = FALSE
		else
			uproot()
	rogue_refresh_look()

/obj/structure/soil/proc/insert_plant(datum/plant_def/new_plant)
	if(plant)
		return
	plant = new_plant
	plant_health = ROGUE_SOIL_MAX_HEALTH
	growth_time = 0
	produce_time = 0
	matured = FALSE
	produce_ready = FALSE
	plant_dead = FALSE
	rogue_refresh_look()

/// The crop's look now (ROGUE_CROP_*), 0 without one.
/obj/structure/soil/proc/crop_look()
	if(!plant)
		return 0
	if(plant_dead)
		return ROGUE_CROP_DEAD
	if(produce_ready)
		return ROGUE_CROP_READY
	return matured ? ROGUE_CROP_MATURE : ROGUE_CROP_GROWING

/// Every threshold the look shows, packed in one number: tilled, the water and nutrition shades, the crop's look and health
/// shade and the weeds.
/obj/structure/soil/proc/rogue_look_key()
	. = (tilled_time > 0) ? 1 : 0
	. += 2 * rogue_shade(water, ROGUE_SOIL_MAX_WATER)
	. += 8 * rogue_shade(nutrition, ROGUE_SOIL_MAX_NUTRITION)
	. += 32 * crop_look()
	. += 256 * rogue_crop_shade()
	. += 1024 * rogue_weed_shade()

/// Ratwood update_overlays() shades of water and nutrition: 0 below 15%, 1 below 60%, 2 above.
/obj/structure/soil/proc/rogue_shade(amount, most)
	if(amount >= most * 0.6)
		return 2
	if(amount >= most * 0.15)
		return 1
	return 0

/// 0 healthy, 1 brown and unhealthy, 2 dying.
/obj/structure/soil/proc/rogue_crop_shade()
	if(!plant || plant_dead)
		return 0
	if(plant_health <= ROGUE_SOIL_MAX_HEALTH * rogue_value("farm_crop_dying"))
		return 2
	if(plant_health <= ROGUE_SOIL_MAX_HEALTH * rogue_value("farm_crop_sick"))
		return 1
	return 0

/// 0 no weeds to see, 1 weeds growing out, 2 overrun.
/obj/structure/soil/proc/rogue_weed_shade()
	if(weeds >= ROGUE_SOIL_MAX_WEEDS * rogue_value("farm_weeds_overgrown"))
		return 2
	if(weeds >= ROGUE_SOIL_MAX_WEEDS * rogue_value("farm_weeds_some"))
		return 1
	return 0

/// Redraws the look when a threshold it shows was crossed (Ratwood redraws it on every event, so its water shade goes stale).
/obj/structure/soil/proc/rogue_refresh_look()
	var/key = rogue_look_key()
	if(key == rogue_look)
		return
	rogue_look = key
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/soil/update_overlays()
	. = ..()
	// Tilled overlay
	if(tilled_time > 0)
		. += mutable_appearance(icon, "soil-tilled")
	// Water overlay
	var/water_shade = rogue_shade(water, ROGUE_SOIL_MAX_WATER)
	if(water_shade)
		var/mutable_appearance/water_ma = mutable_appearance(icon, "soil-overlay")
		water_ma.color = "#000033"
		water_ma.alpha = water_shade == 2 ? 100 : 50
		. += water_ma
	// Nutriment overlay
	var/nutrition_shade = rogue_shade(nutrition, ROGUE_SOIL_MAX_NUTRITION)
	if(nutrition_shade)
		var/mutable_appearance/nutri_ma = mutable_appearance(icon, "soil-overlay")
		nutri_ma.color = "#6d3a00"
		nutri_ma.alpha = nutrition_shade == 2 ? 50 : 25
		. += nutri_ma
	// Plant overlay
	if(plant)
		var/look = crop_look()
		var/mutable_appearance/plant_ma = mutable_appearance(plant.icon, plant.stage_state(look))
		switch(rogue_crop_shade())
			if(2)
				plant_ma.color = "#9c7b43"
			if(1)
				plant_ma.color = "#d8b573"
		if(look == ROGUE_CROP_DEAD && plant.dead_look_missing)
			plant_ma.color = "#9c7b43"
		. += plant_ma
	// Weeds overlay
	switch(rogue_weed_shade())
		if(2)
			. += mutable_appearance(icon, "weeds-2")
		if(1)
			. += mutable_appearance(icon, "weeds-1")

/obj/structure/soil/examine(mob/user)
	. = ..()
	var/farming_skill = 0
	var/can_read_growth_timers = FALSE
	var/can_read_soil_stats = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		farming_skill = living_user.rogue_learned_rank(ROGUE_FARMING_SKILL)
		can_read_growth_timers = farming_skill >= ROGUE_RANK_EXPERT || HAS_TRAIT(living_user, TRAIT_SEEDKNOW)
		can_read_soil_stats = farming_skill >= ROGUE_RANK_APPRENTICE || HAS_TRAIT(living_user, TRAIT_SEEDKNOW)
	// Plant description
	if(plant)
		. += span_info("\The [plant.name] is growing here...")
		// Plant health feedback
		if(farming_skill >= ROGUE_RANK_JOURNEYMAN)
			. += span_info("Crop health: [round((plant_health / ROGUE_SOIL_MAX_HEALTH) * 100)]%")
			if(plant_dead)
				. += span_warning("It's dead!")
			else
				switch(rogue_crop_shade())
					if(2)
						. += span_warning("It's dying!")
					if(1)
						. += span_warning("It's brown and unhealthy...")
		// Plant maturation and produce feedback
		if(matured)
			. += span_info("It's fully matured.")
			if(can_read_growth_timers && !produce_ready)
				. += span_info("Next harvest in approximately [DisplayTimeText(rogue_time_at_rate(plant.produce_time - produce_time, calculate_growth_multiplier()))] (at current growth rate).")
		else
			. += span_info("It has yet to mature.")
			if(can_read_growth_timers)
				. += span_info("Estimated time to maturity: [DisplayTimeText(rogue_time_at_rate(plant.maturation_time - growth_time, calculate_growth_multiplier()))] (at current growth rate).")
		if(produce_ready)
			. += span_info("It's ready for harvest.")
	else
		. += rogue_custom_growth_examine(can_read_growth_timers)
	if(can_read_soil_stats)
		. += span_info("Water: [round((water / ROGUE_SOIL_MAX_WATER) * 100)]%")
		. += span_info("Nutrition: [round((nutrition / ROGUE_SOIL_MAX_NUTRITION) * 100)]%")
	else
		// Water feedback
		if(water <= ROGUE_SOIL_MAX_WATER * 0.15)
			. += span_warning("The soil is thirsty.")
		else if(water <= ROGUE_SOIL_MAX_WATER * 0.5)
			. += span_info("The soil is moist.")
		else
			. += span_info("The soil is wet.")
		// Nutrition feedback
		if(nutrition <= ROGUE_SOIL_MAX_NUTRITION * 0.15)
			. += span_warning("The soil is hungry.")
		else if(nutrition <= ROGUE_SOIL_MAX_NUTRITION * 0.5)
			. += span_info("The soil is sated.")
		else
			. += span_info("The soil looks fertile.")
	// Weeds feedback
	switch(rogue_weed_shade())
		if(2)
			. += span_warning("It's overtaken by the weeds!")
		if(1)
			. += span_warning("Weeds are growing out...")
	if(tilled_time > 0)
		. += span_info("The soil is tilled.")
	if(blessed_time > 0)
		. += span_good("The soil seems blessed.")
	if(fertilized_time > 0)
		. += span_good("The soil has special fertilizer mixed in.")
	if(pollination_time > 0)
		. += span_good("The soil has been pollinated.")
	// Growth bonus breakdown: visible to expert farmers and those with the seedknow trait.
	var/bonus = get_natural_growth_bonus()
	if(can_read_growth_timers && bonus > 0)
		. += span_good("Growth bonus: [round(bonus * 100)]% (blessed soil ([round(bonus * 100)]%).)")

/// Deciseconds of growth left, in real time at this growth rate (Ratwood round(time / multiplier)).
/obj/structure/soil/proc/rogue_time_at_rate(growth_left, multiplier)
	growth_left = max(growth_left, 0)
	return multiplier > 0 ? round(growth_left / multiplier) : growth_left

/// Ratwood examine() of the saplings and seedlings sharing this soil, which do not use its crop: their stage and, for those who
/// read growth, the time to the next.
/obj/structure/soil/proc/rogue_custom_growth_examine(can_read_growth_timers)
	. = list()
	var/turf/here = get_turf(src)
	if(!here)
		return
	var/obj/structure/tree_sapling/tree = locate() in here
	var/obj/structure/bush_sapling/bush = locate() in here
	var/obj/structure/soil_seedling/seedling = locate() in here
	var/multiplier = get_environmental_growth_multiplier()
	if(tree)
		if(tree.dead)
			. += span_warning("A withered sapling is here. Shovel it out to clear the spot.")
			return
		switch(tree.stage)
			if(ROGUE_TREESAP_SAPLING)
				. += span_info("A young tree sapling is taking root here.")
			if(ROGUE_TREESAP_SHRUB)
				. += span_info("A small shrub is growing steadily here.")
		if(can_read_growth_timers && tree.stage <= ROGUE_TREESAP_SHRUB)
			. += span_info("Estimated time to next stage: [DisplayTimeText(rogue_time_at_rate(rogue_value("farm_tree_stage_time") - tree.growth_progress, multiplier))] (at current growth rate).")
	else if(bush)
		if(bush.dead)
			. += span_warning("A withered bush sprout is here. Shovel it out to clear the spot.")
			return
		switch(bush.stage)
			if(ROGUE_BUSHSAP_SAPLING)
				. += span_info("A young bush sprout is taking root here.")
			if(ROGUE_BUSHSAP_BUDDING)
				. += span_info("A bush sprout is growing, still rooted in the soil.")
		if(can_read_growth_timers && bush.stage < ROGUE_BUSHSAP_MATURE)
			. += span_info("Estimated time to next stage: [DisplayTimeText(rogue_time_at_rate(rogue_value("farm_bush_stage_time") - bush.growth_progress, multiplier))] (at current growth rate).")
	else if(seedling)
		. += span_info("A seedling is germinating here.")
		if(can_read_growth_timers)
			. += span_info("Estimated time to bloom: [DisplayTimeText(rogue_time_at_rate(seedling.grow_duration - seedling.growth_progress, multiplier))] (at current growth rate).")
