#define MAX_ARTIFACT_ROLL_CHANCE 10

#define MINERAL_TYPE_OPTIONS_RANDOM 4
#define MINERAL_TYPE_OPTIONS_BOSS 8

/obj/structure/ore_vent
	name = "ore vent"
	desc = "An ore vent, brimming with underground ore. Scan with an advanced mining scanner to start extracting ore from it."
	icon = 'icons/obj/mining_zones/terrain.dmi' /// note to self, new sprites. get on it
	icon_state = "ore_vent"
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //This thing will take a beating.
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE

	/// Has this vent been tapped to produce boulders? Cannot be untapped.
	var/tapped = FALSE
	/// Has this vent been scanned by a mining scanner? Cannot be scanned again. Adds ores to the vent's description.
	var/discovered = FALSE
	/// Is this type of vent exempt from the 15 vent limit? Think the free iron/glass vent or boss vents. This also causes it to not roll for random mineral breakdown.
	var/unique_vent = FALSE
	/// A weighted list of what minerals are contained in this vent, with weight determining how likely each mineral is to be picked in produced boulders.
	var/list/mineral_breakdown = list()
	/// A list of mobs that can be spawned by this vent during a wave defense event.
	var/list/defending_mobs = list(
		/mob/living/basic/mining/goliath,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril,
		/mob/living/basic/mining/watcher,
		/mob/living/basic/mining/lobstrosity/lava,
		/mob/living/simple_animal/hostile/asteroid/brimdemon,
		/mob/living/basic/mining/bileworm
	)
	/// How many rolls on the mineral_breakdown list are made per boulder produced? EG: 3 rolls means 3 minerals per boulder, with order determining percentage.
	var/minerals_per_boulder = 3
	/// How many minerals are picked to be in the ore vent? These are added to the mineral_breakdown list.
	var/minerals_per_breakdown = MINERAL_TYPE_OPTIONS_RANDOM
	/// What size boulders does this vent produce?
	var/boulder_size = BOULDER_SIZE_SMALL
	/// Reference to this ore vent's NODE drone, to track wave success.
	var/mob/living/basic/node_drone/node = null //this path is a placeholder.
	/// Percent chance that this vent will produce an artifact boulder.
	var/artifact_chance = 0
	/// String of ores that this vent can produce.
	var/ore_string = ""


/obj/structure/ore_vent/Initialize(mapload)
	generate_description()
	register_context()
	SSore_generation.possible_vents += src
	if(tapped)
		SSore_generation.processed_vents += src
	. = ..()
	///This is the part where we start processing to produce a new boulder over time.

/obj/structure/ore_vent/Destroy()
	. = ..()
	SSore_generation.possible_vents -= src
	node = null
	if(tapped)
		SSore_generation.processed_vents -= src

/obj/structure/ore_vent/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/t_scanner/adv_mining_scanner))
		if(tapped)
			visible_message(span_notice("\the [src] has already been tapped!"))
			return
		scan_and_confirm(user)

/obj/structure/ore_vent/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	if(tapped)
		return FALSE
	if(istype(M, /mob/living/basic/node_drone))
		return TRUE

/obj/structure/ore_vent/examine(mob/user)
	. = ..()
	if(discovered)
		. += span_notice("This vent can produce [ore_string]")
	else
		. += span_notice("This vent can be scanned with a [span_bold("Mining Scanner")].")

/obj/structure/ore_vent/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	// single use lights can be toggled on once
	if(istype(held_item, /obj/item/t_scanner/adv_mining_scanner))
		context[SCREENTIP_CONTEXT_LMB] = "Scan vent"
		return CONTEXTUAL_SCREENTIP_SET

/**
 * Picks n types materials to pack into a boulder created by this ore vent, where n is this vent's minerals_per_boulder.
 * Then assigns custom_materials based on boulder_size, assigned via the ore_quantity_function
 */
/obj/structure/ore_vent/proc/create_mineral_contents()

	var/list/refined_list = list()
	for(var/iteration in 1 to minerals_per_boulder)
		var/datum/material/material = pick_weight(mineral_breakdown)
		refined_list.Insert(refined_list.len, material)
		refined_list[material] += ore_quantity_function(iteration)
	return refined_list

/obj/structure/ore_vent/proc/generate_mineral_breakdown()
	var/iterator = 1
	while(iterator <= MINERAL_TYPE_OPTIONS_RANDOM)
		if(SSore_generation.ore_vent_minerals.len == 0)
			CRASH("No minerals left to pick from! We may have spawned too many ore vents in init, or added too many ores to the existing vents.")
		var/datum/material/material = pick_weight(SSore_generation.ore_vent_minerals)
		if(is_type_in_list(mineral_breakdown, material))
			continue
		priority_announce("[material.name] is the material picked.")
		//We remove 1 from the ore vent's mineral breakdown weight, so that it can't be picked again.
		SSore_generation.ore_vent_minerals[material] -= 1
		if(SSore_generation.ore_vent_minerals[material] <= 0)
			SSore_generation.ore_vent_minerals.Remove(material)
		mineral_breakdown[material] = rand(1,4)
		iterator++


/**
 * Returns the quantity of mineral sheets in each ore's boulder contents roll. First roll can produce the most ore, with subsequent rolls scaling lower logarithmically.
 */
/obj/structure/ore_vent/proc/ore_quantity_function(ore_floor)
	var/mineral_count = boulder_size * (log(rand(1+ore_floor, 4+ore_floor))**-1)
	mineral_count = SHEET_MATERIAL_AMOUNT * round(mineral_count)
	return mineral_count

/**
 * Starts the wave defense event, which will spawn a number of lavaland mobs based on the size of the ore vent.
 * Called after the vent has been tapped by a scanning device.
 * Will summon a number of waves of mobs, ending in the vent being tapped after the final wave.
 */
/obj/structure/ore_vent/proc/start_wave_defense()
	//faction = FACTION_MINING,	//todo: is there some reason I can't sanity check mob faction?
	AddComponent(/datum/component/spawner,\
		spawn_types = defending_mobs,\
		spawn_time = 15 SECONDS,\
		max_spawned = 10,\
		spawn_per_attempt = (1 + (boulder_size/5)),\
		spawn_text = "emerges to assault",\
		spawn_distance = 4,\
		spawn_distance_exclude = 3)
	var/wave_timer = 20 SECONDS
	if(boulder_size == BOULDER_SIZE_MEDIUM)
		wave_timer = 40 SECONDS
	else if(boulder_size == BOULDER_SIZE_LARGE)
		wave_timer = 60 SECONDS

	addtimer(CALLBACK(src, PROC_REF(handle_wave_conclusion)), wave_timer)

/obj/structure/ore_vent/proc/handle_wave_conclusion()
	SEND_SIGNAL(src, COMSIG_MINING_SPAWNER_STOP)
	if(node) ///The Node Drone has survived the wave defense, and the ore vent is tapped.
		tapped = TRUE
		SSore_generation.processed_vents += src
	else
		//Wave defense is failed, and the ore vent downgrades one tier, capping at small.
		if(boulder_size == BOULDER_SIZE_LARGE)
			boulder_size = BOULDER_SIZE_MEDIUM
			visible_message(span_danger("\the [src] crumbles as the mining attempt fails, and the ore vent partially closes up!"))
		else if(boulder_size == BOULDER_SIZE_MEDIUM)
			boulder_size = BOULDER_SIZE_SMALL
			visible_message(span_danger("\the [src] crumbles as the mining attempt fails, and the ore vent is left damaged!"))
		else
			visible_message(span_danger("\the [src] creaks and groans as the mining attempt fails, but stays it's current size."))
		return FALSE //Band end, try again.

	for(var/potential_miner as anything in oview(5))
		if(ishuman(potential_miner))
			var/mob/living/carbon/human/true_miner = potential_miner
			var/obj/item/card/id/user_id_card = true_miner.get_idcard(TRUE)
			if(!user_id_card)
				continue
			if(user_id_card)
				var/point_reward_val = MINER_POINT_MULTIPLIER * boulder_size
				user_id_card.registered_account.mining_points += (point_reward_val)
				user_id_card.registered_account.bank_card_talk("You have been awarded [point_reward_val] mining points for your efforts.")
	node.escape() //Visually show the drone is done and flies away.
	icon_state = "ore_vent_active"
	update_appearance(UPDATE_ICON_STATE)

/**
 * Called when the ore vent is tapped by a scanning device.
 * Gives a readout of the ores available in the vent that gets added to the description, then asks the user if they want to start wave defense.
 */
/obj/structure/ore_vent/proc/scan_and_confirm(mob/user)
	if(!discovered)
		if(do_after(user, 4 SECONDS))
			discovered = TRUE
			generate_description()
			return
		else
			return
	if(tgui_alert(usr, "Are you ready to excavate \the [src]?", "Uh oh", list("Yes", "No")) != "Yes")
		return
	///This is where we start spitting out mobs.
	Shake(duration = 3 SECONDS)
	node = new /mob/living/basic/node_drone(loc)
	node.arrive()

	for(var/i in 1 to 5) // Clears the surroundings of the ore vent before starting wave defense.
		for(var/turf/closed/mineral/rock in oview(i))
			if(istype(rock, /turf/open/misc/asteroid) && prob(45)) // so it's too common
				new /obj/effect/decal/cleanable/rubble(rock)
			if(!istype(rock, /turf/closed/mineral))
				continue
			rock.gets_drilled(user, FALSE)
			if(prob(75))
				new /obj/effect/decal/cleanable/rubble(rock)
		sleep(0.6 SECONDS)

	start_wave_defense()

/obj/structure/ore_vent/proc/generate_description()
	for(var/mineral_count in 1 to mineral_breakdown.len)
		var/datum/material/resource = mineral_breakdown[mineral_count]
		if(mineral_count == mineral_breakdown.len)
			ore_string += "and " + resource.name + "."
		else
			ore_string += resource.name + ", "

//comes with the station, and is already tapped.
/obj/structure/ore_vent/starter_resources
	name = "active ore vent"
	desc = "An ore vent, brimming with underground ore. It's already supplying the station with iron and glass."
	icon_state = "ore_vent_active"
	tapped = TRUE
	discovered = TRUE
	unique_vent = TRUE
	boulder_size = BOULDER_SIZE_SMALL
	mineral_breakdown = list(
		/datum/material/iron = 50,
		/datum/material/glass = 50,
	)

/obj/structure/ore_vent/random
	/// Static list of ore vent types, for random generation.
	var/static/list/ore_vent_types = list(
		BOULDER_SIZE_SMALL,
		BOULDER_SIZE_MEDIUM,
		BOULDER_SIZE_LARGE,
	)

/obj/structure/ore_vent/random/Initialize(mapload)
	. = ..()
	if(!unique_vent)
		generate_mineral_breakdown()
	var/string_boulder_size = pick_weight(SSore_generation.ore_vent_sizes)
	switch(string_boulder_size)
		if("large")
			boulder_size = BOULDER_SIZE_LARGE
			SSore_generation.ore_vent_sizes["large"] -= 1
		if("medium")
			boulder_size = BOULDER_SIZE_MEDIUM
			SSore_generation.ore_vent_sizes["medium"] -= 1
		if("small")
			boulder_size = BOULDER_SIZE_SMALL
			SSore_generation.ore_vent_sizes["small"] -= 1
	artifact_chance = rand(0, MAX_ARTIFACT_ROLL_CHANCE)

/obj/structure/ore_vent/random/icebox
	defending_mobs = list(
		/mob/living/basic/mining/ice_whelp,
		/mob/living/basic/mining/lobstrosity,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow,
		/mob/living/simple_animal/hostile/asteroid/ice_demon,
		/mob/living/simple_animal/hostile/asteroid/polarbear,
		/mob/living/simple_animal/hostile/asteroid/wolf
	)

/obj/structure/ore_vent/boss
	name = "menacing ore vent"
	desc = "An ore vent, brimming with underground ore. This one has an evil aura about it. Better be careful."
	unique_vent = TRUE
	boulder_size = BOULDER_SIZE_LARGE
	mineral_breakdown = list(
		/datum/material/iron = 1,
		/datum/material/glass = 1,
		/datum/material/plasma = 1,
		/datum/material/titanium = 1,
		/datum/material/silver = 1,
		/datum/material/gold = 1,
		/datum/material/diamond = 1,
		/datum/material/uranium = 1,
		/datum/material/bluespace = 1,
		/datum/material/plastic = 1
	)
	defending_mobs = list(
		/mob/living/simple_animal/hostile/megafauna/bubblegum,
		/mob/living/simple_animal/hostile/megafauna/dragon,
		/mob/living/simple_animal/hostile/megafauna/colossus
	)
	///What boss do we want to spawn?
	var/summoned_boss = null

/obj/structure/ore_vent/boss/Initialize(mapload)
	. = ..()
	summoned_boss = pick(defending_mobs)

/obj/structure/ore_vent/boss/examine(mob/user)
	. = ..()
	var/boss_string = ""
	switch(summoned_boss)
		if(/mob/living/simple_animal/hostile/megafauna/bubblegum)
			boss_string = "A giant fleshbound beast"
		if(/mob/living/simple_animal/hostile/megafauna/dragon)
			boss_string = "Sharp teeth and scales"
		if(/mob/living/simple_animal/hostile/megafauna/colossus)
			boss_string = "A giant, armored behemoth"
		if(/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner)
			boss_string = "A bloody drillmark"
		if(/mob/living/simple_animal/hostile/megafauna/wendigo)
			boss_string = "A chilling skull"
	. += span_notice("[boss_string] is etched onto the side of the vent.")

/obj/structure/ore_vent/boss/start_wave_defense()
	// Completely override the normal wave defense, and just spawn the boss.
	var/mob/living/simple_animal/boss = new summoned_boss(loc)
	RegisterSignal(boss, COMSIG_LIVING_DEATH, PROC_REF(handle_wave_conclusion)) ///Lets hope this is how this works
	boss.say("You dare disturb my slumber?!") //to stop warnings namely

/obj/structure/ore_vent/boss/handle_wave_conclusion()
	node = new /mob/living/basic/node_drone(loc) //We're spawning the vent after the boss dies, so the player can just focus on the boss.
	. = ..()

/obj/structure/ore_vent/boss/icebox
	defending_mobs = list(
		/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner,
		/mob/living/simple_animal/hostile/megafauna/wendigo,
		/mob/living/simple_animal/hostile/megafauna/colossus
	)

#undef MAX_ARTIFACT_ROLL_CHANCE
#undef MINERAL_TYPE_OPTIONS_RANDOM
#undef MINERAL_TYPE_OPTIONS_BOSS
