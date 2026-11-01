/// Ratwood's wild plants (code/modules/farming/wild_plant.dm): a crop growing wild, ripe, which one picking takes whole. A wild
/// plant may spread to the free dirt, grass and snow around it when it appears, less likely every generation. Ratwood's code
/// never gets that far (it checks the crop as an instance while it is still a type), so its wild plants keep their map look,
/// never spread and cannot be picked; this does what that code was meant to.
/obj/structure/wild_plant
	/// The crop it is (Ratwood plant_type).
	var/datum/plant_def/plant_type
	/// Chance in percent it spreads to a free neighbouring tile when it appears (Ratwood spread_chance).
	var/spread_chance = 75

/obj/structure/wild_plant/nospread
	spread_chance = 0

/obj/structure/wild_plant/nospread/manabloom
	plant_type = /datum/plant_def/manabloom

/obj/structure/wild_plant/Initialize(mapload, datum/plant_def/incoming_type, incoming_spread)
	. = ..()
	if(ispath(incoming_type, /datum/plant_def))
		plant_type = incoming_type
	if(isnum(incoming_spread))
		spread_chance = incoming_spread
	var/datum/plant_def/plant = GLOB.rogue_plant_defs[plant_type]
	if(!plant)
		return
	if(type == /obj/structure/wild_plant)
		name = "wild [plant.name]"
		desc = "A wild [plant.name]."
	icon = plant.icon
	icon_state = plant.stage_state(ROGUE_CROP_READY)
	pixel_x = rand(-12, 12)
	pixel_y = rand(-12, 12)
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)
	if(prob(spread_chance))
		try_spread()

/obj/structure/wild_plant/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(isliving(arrived))
		playsound(src, pick(ROGUE_PLANTCROSS_SOUNDS), 80, FALSE, -1)

/obj/structure/wild_plant/proc/try_spread()
	for(var/direction in shuffle(GLOB.cardinals))
		var/turf/open/next = get_step(src, direction)
		if(!istype(next, /turf/open/floor/rogue/dirt) && !istype(next, /turf/open/floor/rogue/grass) && !istype(next, /turf/open/floor/rogue/snow))
			continue
		if((locate(/obj/structure/wild_plant) in next) || next.is_blocked_turf(exclude_mobs = TRUE))
			continue
		new /obj/structure/wild_plant(next, plant_type, spread_chance - rogue_value("farm_wild_spread_falloff"))
		if(!prob(spread_chance))
			return

/obj/structure/wild_plant/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user) || !GLOB.rogue_plant_defs[plant_type])
		return
	INVOKE_ASYNC(src, PROC_REF(pick_plant), user)
	return TRUE

/obj/structure/wild_plant/proc/pick_plant(mob/living/user)
	if(!do_after(user, user.rogue_farming_time(rogue_value("farm_wild_harvest_time")), target = src))
		return
	playsound(src, ROGUE_SEED_SOUND, 100, FALSE)
	user_harvests(user)

/obj/structure/wild_plant/proc/user_harvests(mob/living/user)
	user.rogue_farming_fatigue(rogue_value("farm_wild_harvest_fatigue"))
	user.rogue_farming_experience(rogue_value("farm_harvest_xp"))
	var/rank_chance = user.rogue_learned_rank(ROGUE_FARMING_SKILL) * rogue_value("farm_harvest_rank_chance")
	if(prob(rogue_value("farm_ruin_chance") - rank_chance))
		to_chat(user, span_warning("I ruin the produce..."))
		qdel(src)
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
	yield_produce(modifier)

/obj/structure/wild_plant/proc/yield_produce(modifier = 0)
	var/datum/plant_def/plant = GLOB.rogue_plant_defs[plant_type]
	if(plant?.can_grow())
		var/spawn_amount = max(rand(plant.produce_amount_min, plant.produce_amount_max) + modifier, 1)
		for(var/i in 1 to spawn_amount)
			new plant.produce_type(loc)
	qdel(src)
