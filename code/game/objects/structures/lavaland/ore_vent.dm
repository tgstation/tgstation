#define MAX_ARTIFACT_ROLL_CHANCE 10
#define MINERAL_TYPE_OPTIONS_RANDOM 4
#define OVERLAY_OFFSET_START 0
#define OVERLAY_OFFSET_EACH 5
#define MINERALS_PER_BOULDER 3

/obj/structure/ore_vent
	name = "ore vent"
	desc = "An ore vent, brimming with underground ore. Scan with an advanced mining scanner to start extracting ore from it."
	icon = 'icons/obj/mining_zones/terrain.dmi'
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
	/// Is this type of vent exempt from the map's vent budget/limit? Think the free iron/glass vent or boss vents. This also causes it to not roll for random mineral breakdown.
	var/unique_vent = FALSE
	/// Does this vent spawn a node drone when tapped? Currently unique to boss vents so try not to VV it.
	var/spawn_drone_on_tap = TRUE
	/// What icon_state do we use when the ore vent has been tapped?
	var/icon_state_tapped = "ore_vent_active"
	/// A weighted list of what minerals are contained in this vent, with weight determining how likely each mineral is to be picked in produced boulders.
	var/list/mineral_breakdown = list()
	/// What size boulders does this vent produce?
	var/boulder_size = BOULDER_SIZE_SMALL
	/// Reference to this ore vent's NODE drone, to track wave success.
	var/mob/living/basic/node_drone/node = null //this path is a placeholder.
	/// String containing the formatted list of ores that this vent can produce, and who first discovered this vent.
	var/ore_string = ""
	/// Associated list of vent size weights to pick from.
	var/list/ore_vent_options = list(
		LARGE_VENT_TYPE = 3,
		MEDIUM_VENT_TYPE = 5,
		SMALL_VENT_TYPE = 7,
	)
	var/wave_timer = WAVE_DURATION_SMALL

	/// What string do we use to warn the player about the excavation event?
	var/excavation_warning = "Are you ready to excavate this ore vent?"
	/// A list of mobs that can be spawned by this vent during a wave defense event.
	var/list/defending_mobs = list(
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/legion/spawner_made,
		/mob/living/basic/mining/watcher,
		/mob/living/basic/mining/lobstrosity/lava,
		/mob/living/basic/mining/brimdemon,
		/mob/living/basic/mining/bileworm,
	)
	///What items can be used to scan a vent?
	var/static/list/scanning_equipment = list(
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/mining_scanner,
	)

	/// What base icon_state do we use for this vent's boulders?
	var/boulder_icon_state = "boulder"
	/// Percent chance that this vent will produce an artifact boulder.
	var/artifact_chance = 0
	/// We use a cooldown to prevent the wave defense from being started multiple times.
	COOLDOWN_DECLARE(wave_cooldown)
	/// We use a cooldown to prevent players from tapping boulders rapidly from vents.
	COOLDOWN_DECLARE(manual_vent_cooldown)

/obj/structure/ore_vent/Initialize(mapload)
	if(mapload)
		generate_description()
	register_context()
	if(!unique_vent)
		SSore_generation.possible_vents += src
	boulder_icon_state = pick(list(
		"boulder",
		"rock",
		"stone",
	))
	if(tapped)
		SSore_generation.processed_vents += src
		icon_state = icon_state_tapped
		update_appearance(UPDATE_ICON_STATE)
		add_overlay(mutable_appearance('icons/obj/mining_zones/terrain.dmi', "well", ABOVE_MOB_LAYER))

	RegisterSignal(src, COMSIG_SPAWNER_SPAWNED_DEFAULT, PROC_REF(anti_cheese))
	RegisterSignal(src, COMSIG_SPAWNER_SPAWNED, PROC_REF(log_mob_spawned))
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_NO_TERRAFORM)))
	return ..()

/obj/structure/ore_vent/Destroy()
	SSore_generation.possible_vents -= src
	node = null
	if(tapped)
		SSore_generation.processed_vents -= src
	return ..()

/obj/structure/ore_vent/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(.)
		return TRUE
	if(!is_type_in_list(attacking_item, scanning_equipment))
		return TRUE
	if(tapped)
		balloon_alert_to_viewers("vent tapped!")
		return TRUE
	scan_and_confirm(user)
	return TRUE

/obj/structure/ore_vent/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		return
	if(!discovered)
		to_chat(user, span_notice("You can't quite find the weakpoint of [src]... Perhaps it needs to be scanned first?"))
		return
	to_chat(user, span_notice("You start striking [src] with your golem's fist, attempting to dredge up a boulder..."))
	for(var/i in 1 to 3)
		if(do_after(user, boulder_size * 1 SECONDS, src))
			user.apply_damage(20, STAMINA)
			playsound(src, 'sound/items/weapons/genhit.ogg', 50, TRUE)
	produce_boulder(TRUE)
	visible_message(span_notice("You've successfully produced a boulder! Boy are your arms tired."))

/obj/structure/ore_vent/attack_basic_mob(mob/user, list/modifiers)
	. = ..()
	if(!HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		return
	produce_boulder(TRUE)

/obj/structure/ore_vent/is_buckle_possible(mob/living/target, force, check_loc)
	. = ..()
	if(tapped)
		return FALSE
	if(istype(target, /mob/living/basic/node_drone))
		return TRUE

/obj/structure/ore_vent/examine(mob/user)
	. = ..()
	if(discovered)
		switch(boulder_size)
			if(BOULDER_SIZE_SMALL)
				. += span_notice("This vent produces [span_bold("small")] boulders containing [ore_string]")
			if(BOULDER_SIZE_MEDIUM)
				. += span_notice("This vent produces [span_bold("medium")] boulders containing [ore_string]")
			if(BOULDER_SIZE_LARGE)
				. += span_notice("This vent produces [span_bold("large")] boulders containing [ore_string]")
	else
		. += span_notice("This vent can be scanned with a [span_bold("Mining Scanner")].")

/obj/structure/ore_vent/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(is_type_in_list(held_item, scanning_equipment))
		context[SCREENTIP_CONTEXT_LMB] = "Scan vent"
		return CONTEXTUAL_SCREENTIP_SET

/**
 * This proc is called when the ore vent is initialized, in order to determine what minerals boulders it spawns can contain.
 * The materials available are determined by SSore_generation.ore_vent_minerals, which is a list of all minerals that can be contained in ore vents for a given cave generation.
 * As a result, minerals use a weighted list as seen by ore_vent_minerals_lavaland, which is then copied to ore_vent_minerals.
 * Once a material is picked from the weighted list, it's removed from ore_vent_minerals, so that it can't be picked again and provided its own internal weight used when assigning minerals to boulders spawned by this vent.
 * May also be called after the fact, as seen in SSore_generation's initialize, to add more minerals to an existing vent.
 *
 * The above applies only when spawning in at mapload, otherwise we pick randomly from ore_vent_minerals_lavaland.
 *
 * @params new_minerals How many minerals should be added to this vent? Defaults to MINERAL_TYPE_OPTIONS_RANDOM, which is 4.
 * @params map_loading Is this vent being spawned in at mapload? If so, we use the ore_generation subsystem's ore_vent_minerals list to pick minerals. Otherwise, we pick randomly from ore_vent_minerals_lavaland.
 */
/obj/structure/ore_vent/proc/generate_mineral_breakdown(new_minerals = MINERAL_TYPE_OPTIONS_RANDOM, map_loading = FALSE)
	if(new_minerals < 1)
		CRASH("generate_mineral_breakdown called with new_minerals < 1.")
	var/list/available_mats = difflist(first = SSore_generation.ore_vent_minerals, second = mineral_breakdown, skiprep = 1)
	for(var/i in 1 to new_minerals)
		if(!length(SSore_generation.ore_vent_minerals) && map_loading)
			// We should prevent this from happening in SSore_generation, but if not then we crash here
			CRASH("No minerals left to pick from! We may have spawned too many ore vents in init, or the map config in seedRuins may not have enough resources for the mineral budget.")
		var/datum/material/new_material
		if(map_loading)
			if(length(available_mats))
				new_material = pick(GLOB.ore_vent_minerals_lavaland)
				var/datum/material/surrogate_mat = pick(SSore_generation.ore_vent_minerals)
				available_mats -= surrogate_mat
				SSore_generation.ore_vent_minerals -= surrogate_mat
			else
				new_material = pick(available_mats)
				available_mats -= new_material
				SSore_generation.ore_vent_minerals -= new_material
		else
			new_material = pick(GLOB.ore_vent_minerals_lavaland)
		mineral_breakdown[new_material] = rand(1, 4)


/**
 * Returns the quantity of mineral sheets in each ore vent's boulder contents roll.
 * First roll can produce the most ore, with subsequent rolls scaling lower logarithmically.
 * Inversely scales with ore_floor, so that the first roll is the largest, and subsequent rolls are smaller.
 * (1 -> from 16 to 7 sheets of materials, and 3 -> from 8 to 6 sheets of materials on a small vent)
 * This also means a large boulder can highroll a boulder with a full stack of 50 sheets of material.
 * @params ore_floor The number of minerals already rolled. Used to scale the logarithmic function.
 */
/obj/structure/ore_vent/proc/ore_quantity_function(ore_floor)
	return SHEET_MATERIAL_AMOUNT * round(boulder_size * (log(rand(1 + ore_floor, 4 + ore_floor)) ** -1))

/**
 * This confirms that the user wants to start the wave defense event, and that they can start it.
 */
/obj/structure/ore_vent/proc/pre_wave_defense(mob/user, spawn_drone = TRUE)
	if(tgui_alert(user, excavation_warning, "Begin defending ore vent?", list("Yes", "No")) != "Yes")
		return FALSE
	if(!can_interact(user))
		return FALSE
	if(!COOLDOWN_FINISHED(src, wave_cooldown) || node)
		return FALSE
	//This is where we start spitting out mobs.
	Shake(duration = 3 SECONDS)
	if(spawn_drone)
		node = new /mob/living/basic/node_drone(loc)
		node.arrive(src)
		RegisterSignal(node, COMSIG_QDELETING, PROC_REF(handle_wave_conclusion))
		RegisterSignal(node, COMSIG_MOVABLE_MOVED, PROC_REF(handle_wave_conclusion))
		addtimer(CALLBACK(node, TYPE_PROC_REF(/atom, update_appearance)), wave_timer * 0.25)
		addtimer(CALLBACK(node, TYPE_PROC_REF(/atom, update_appearance)), wave_timer * 0.5)
		addtimer(CALLBACK(node, TYPE_PROC_REF(/atom, update_appearance)), wave_timer * 0.75)
	particles = new /particles/smoke/ash()
	for(var/i in 1 to 5) // Clears the surroundings of the ore vent before starting wave defense.
		for(var/turf/closed/mineral/rock in oview(i))
			if(istype(rock, /turf/open/misc/asteroid) && prob(35)) // so it's too common
				new /obj/effect/decal/cleanable/rubble(rock)
			if(prob(100 - (i * 15)))
				rock.gets_drilled(user, FALSE)
				if(prob(50))
					new /obj/effect/decal/cleanable/rubble(rock)
		sleep(0.6 SECONDS)
	return TRUE

/**
 * Starts the wave defense event, which will spawn a number of lavaland mobs based on the size of the ore vent.
 * Called after the vent has been tapped by a scanning device.
 * Will summon a number of waves of mobs, ending in the vent being tapped after the final wave.
 */
/obj/structure/ore_vent/proc/start_wave_defense()
	AddComponent(\
		/datum/component/spawner, \
		spawn_types = defending_mobs, \
		spawn_time = (10 SECONDS + (5 SECONDS * (boulder_size/5))), \
		max_spawned = 10, \
		max_spawn_per_attempt = (1 + (boulder_size/5)), \
		spawn_text = "emerges to assault", \
		spawn_distance = 4, \
		spawn_distance_exclude = 3, \
	)
	COOLDOWN_START(src, wave_cooldown, wave_timer)
	addtimer(CALLBACK(src, PROC_REF(handle_wave_conclusion)), wave_timer)
	icon_state = icon_state_tapped
	update_appearance(UPDATE_ICON_STATE)

/**
 * Called when the wave defense event ends, after a variable amount of time in start_wave_defense.
 *
 * If the node drone is still alive, the ore vent is tapped and the ore vent will begin generating boulders.
 * If the node drone is dead, the ore vent is not tapped and the wave defense can be reattempted.
 *
 * Also gives xp and mining points to all nearby miners in equal measure.
 * Arguments:
 * - force: Set to true if you want to just skip all checks and make the vent start producing boulders.
 */
/obj/structure/ore_vent/proc/handle_wave_conclusion(force = FALSE)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_VENT_WAVE_CONCLUDED)
	COOLDOWN_RESET(src, wave_cooldown)
	particles = null

	if(QDELETED(node) && !force)
		visible_message(span_danger("\the [src] creaks and groans as the mining attempt fails, and the vent closes back up."))
		icon_state = initial(icon_state)
		update_appearance(UPDATE_ICON_STATE)
		node = null
		return //Bad end, try again.
	else if(!QDELETED(node) && get_turf(node) != get_turf(src) && !force)
		visible_message(span_danger("The [node] detaches from the [src], and the vent closes back up!"))
		icon_state = initial(icon_state)
		update_appearance(UPDATE_ICON_STATE)
		UnregisterSignal(node, COMSIG_MOVABLE_MOVED)
		node.pre_escape(success = FALSE)
		node = null
		return //Start over!

	tapped = TRUE //The Node Drone has survived the wave defense, and the ore vent is tapped.
	SSore_generation.processed_vents += src
	log_game("Ore vent [key_name_and_tag(src)] was tapped")
	SSblackbox.record_feedback("tally", "ore_vent_completed", 1, type)
	balloon_alert_to_viewers("vent tapped!")
	icon_state = icon_state_tapped
	update_appearance(UPDATE_ICON_STATE)
	qdel(GetComponent(/datum/component/gps))
	UnregisterSignal(node, COMSIG_QDELETING)

	for(var/mob/living/miner in range(7, src)) //Give the miners who are near the vent points and xp.
		var/obj/item/card/id/user_id_card = miner.get_idcard(TRUE)
		if(miner.stat <= SOFT_CRIT)
			miner.mind?.adjust_experience(/datum/skill/mining, MINING_SKILL_BOULDER_SIZE_XP * boulder_size)
		if(!user_id_card)
			continue
		var/point_reward_val = (MINER_POINT_MULTIPLIER * boulder_size) - MINER_POINT_MULTIPLIER // We remove the base value of discovering the vent
		if(user_id_card.registered_account)
			user_id_card.registered_account.mining_points += point_reward_val
			user_id_card.registered_account.bank_card_talk("You have been awarded [point_reward_val] mining points for your efforts.")
	node?.pre_escape() //Visually show the drone is done and flies away.
	node = null
	add_overlay(mutable_appearance('icons/obj/mining_zones/terrain.dmi', "well", ABOVE_MOB_LAYER))

/**
 * Called when the ore vent is tapped by a scanning device.
 * Gives a readout of the ores available in the vent that gets added to the description,
 * then asks the user if they want to start wave defense if it's already been discovered.
 * @params user The user who tapped the vent.
 * @params scan_only If TRUE, the vent will only scan, and not prompt to start wave defense. Used by the mech mineral scanner.
 */
/obj/structure/ore_vent/proc/scan_and_confirm(mob/living/user, scan_only = FALSE)
	if(tapped)
		balloon_alert_to_viewers("vent tapped!")
		return
	if(!COOLDOWN_FINISHED(src, wave_cooldown) || node) //We're already defending the vent, so don't scan it again.
		if(!scan_only)
			balloon_alert_to_viewers("protect the node drone!")
		return
	if(!discovered)
		if(scan_only)
			discovered = TRUE
			generate_description(user)
			balloon_alert_to_viewers("vent scanned!")
			AddComponent(/datum/component/gps, name)
			return

		if(DOING_INTERACTION_WITH_TARGET(user, src))
			balloon_alert(user, "already scanning!")
			return
		balloon_alert(user, "scanning...")
		playsound(src, 'sound/items/timer.ogg', 30, TRUE)
		if(!do_after(user, 4 SECONDS, src))
			return

		discovered = TRUE
		balloon_alert(user, "vent scanned!")
		generate_description(user)
		AddComponent(/datum/component/gps, name)
		var/obj/item/card/id/user_id_card = user.get_idcard(TRUE)
		if(isnull(user_id_card))
			return
		if(user_id_card.registered_account)
			user_id_card.registered_account.mining_points += (MINER_POINT_MULTIPLIER)
			user_id_card.registered_account.bank_card_talk("You've been awarded [MINER_POINT_MULTIPLIER] mining points for discovery of an ore vent.")
		return
	if(scan_only)
		return

	if(!pre_wave_defense(user, spawn_drone_on_tap))
		return
	start_wave_defense()

/**
 * Generates a description of the ore vent to ore_string, based on the minerals contained within it.
 * Ore_string is passed to examine().
 */
/obj/structure/ore_vent/proc/generate_description(mob/user)
	ore_string = ""
	var/list/mineral_names = list()
	for(var/datum/material/resource as anything in mineral_breakdown)
		mineral_names += initial(resource.name)

	ore_string = "[english_list(mineral_names)]."
	if(user)
		ore_string += "\nThis vent was first discovered by [user]."
/**
 * Adds floating temp_visual overlays to the vent, showcasing what minerals are contained within it.
 * If undiscovered, adds a single overlay with the icon_state "unknown".
 */
/obj/structure/ore_vent/proc/add_mineral_overlays()
	if(mineral_breakdown.len && !discovered)
		var/obj/effect/temp_visual/mining_overlay/vent/new_mat = new /obj/effect/temp_visual/mining_overlay/vent(drop_location())
		new_mat.icon_state = "unknown"
		return
	for(var/datum/material/selected_mat as anything in mineral_breakdown)
		var/obj/effect/temp_visual/mining_overlay/vent/new_mat = new /obj/effect/temp_visual/mining_overlay/vent(drop_location())
		new_mat.icon_state = selected_mat.name

/**
 * Here is where we handle producing a new boulder, based on the qualities of this ore vent.
 * Returns the boulder produced.
 * @params apply_cooldown Should we apply a cooldown to producing boulders? Default's false, used by manual boulder production (goldgrubs, golems, etc).
 */
/obj/structure/ore_vent/proc/produce_boulder(apply_cooldown = FALSE)
	RETURN_TYPE(/obj/item/boulder)

	//cooldown applies only for manual processing by hand
	if(apply_cooldown && !COOLDOWN_FINISHED(src, manual_vent_cooldown))
		return

	//produce the boulder
	var/obj/item/boulder/new_rock
	if(prob(artifact_chance))
		new_rock = new /obj/item/boulder/artifact(loc)
	else
		new_rock = new /obj/item/boulder(loc)
	Shake(duration = 1.5 SECONDS)

	//decorate the boulder with materials
	var/list/mats_list = list()
	for(var/iteration in 1 to MINERALS_PER_BOULDER)
		var/datum/material/material = pick_weight(mineral_breakdown)
		mats_list[material] += ore_quantity_function(iteration)
	new_rock.set_custom_materials(mats_list)

	//set size & durability
	new_rock.boulder_size = boulder_size
	new_rock.durability = rand(2, boulder_size) //randomize durability a bit for some flavor.
	new_rock.boulder_string = boulder_icon_state
	new_rock.update_appearance(UPDATE_ICON_STATE)

	//start the cooldown & return the boulder
	if(apply_cooldown)
		COOLDOWN_START(src, manual_vent_cooldown, 10 SECONDS)
	return new_rock

/**
 * When the ore vent cannot spawn a mob due to being blocked from all sides, we cause some MILD, MILD explosions.
 * Explosion matches a gibtonite light explosion, as a way to clear nearby solid structures, with a high likelihood of breaking the NODE drone.
 */
/obj/structure/ore_vent/proc/anti_cheese()
	explosion(src, heavy_impact_range = 1, light_impact_range = 3, flame_range = 0, flash_range = 0, adminlog = FALSE)

/**
 * Handle logging for mobs spawned
 */
/obj/structure/ore_vent/proc/log_mob_spawned(datum/source, mob/living/created)
	SIGNAL_HANDLER
	log_game("Ore vent [key_name_and_tag(src)] spawned the following mob: [key_name_and_tag(created)]")
	SSblackbox.record_feedback("tally", "ore_vent_mobs_spawned", 1, created.type)
	RegisterSignal(created, COMSIG_LIVING_DEATH, PROC_REF(log_mob_killed))

/**
 * Handle logging for mobs killed
 */
/obj/structure/ore_vent/proc/log_mob_killed(datum/source, mob/living/killed)
	SIGNAL_HANDLER
	log_game("Vent-spawned mob [key_name_and_tag(killed)] was killed")
	SSblackbox.record_feedback("tally", "ore_vent_mobs_killed", 1, killed.type)

//comes with the station, and is already tapped.
/obj/structure/ore_vent/starter_resources
	name = "active ore vent"
	desc = "An ore vent, brimming with underground ore. It's already supplying the station with iron and glass."
	tapped = TRUE
	discovered = TRUE
	unique_vent = TRUE
	boulder_size = BOULDER_SIZE_SMALL
	mineral_breakdown = list(
		/datum/material/iron = 50,
		/datum/material/glass = 50,
	)

/obj/structure/ore_vent/random

/obj/structure/ore_vent/random/Initialize(mapload)
	. = ..()
	if(!unique_vent && !mapload)
		generate_mineral_breakdown(map_loading = mapload) //Default to random mineral breakdowns, unless this is a unique vent or we're still setting up default vent distribution.
		generate_description()
	artifact_chance = rand(0, MAX_ARTIFACT_ROLL_CHANCE)
	var/string_boulder_size = pick_weight(ore_vent_options)
	name = "[string_boulder_size] ore vent"
	switch(string_boulder_size)
		if(LARGE_VENT_TYPE)
			boulder_size = BOULDER_SIZE_LARGE
			wave_timer = WAVE_DURATION_LARGE
			if(mapload)
				GLOB.ore_vent_sizes["large"] += 1
		if(MEDIUM_VENT_TYPE)
			boulder_size = BOULDER_SIZE_MEDIUM
			wave_timer = WAVE_DURATION_MEDIUM
			if(mapload)
				GLOB.ore_vent_sizes["medium"] += 1
		if(SMALL_VENT_TYPE)
			boulder_size = BOULDER_SIZE_SMALL
			wave_timer = WAVE_DURATION_SMALL
			if(mapload)
				GLOB.ore_vent_sizes["small"] += 1
		else
			boulder_size = BOULDER_SIZE_SMALL //Might as well set a default value
			wave_timer = WAVE_DURATION_SMALL
			name = initial(name)



/obj/structure/ore_vent/random/icebox //The one that shows up on the top level of icebox
	icon_state = "ore_vent_ice"
	icon_state_tapped = "ore_vent_ice_active"
	defending_mobs = list(
		/mob/living/basic/mining/lobstrosity,
		/mob/living/basic/mining/legion/snow/spawner_made,
		/mob/living/basic/mining/wolf,
		/mob/living/simple_animal/hostile/asteroid/polarbear,
	)
	ore_vent_options = list(
		SMALL_VENT_TYPE,
	)

/obj/structure/ore_vent/random/icebox/lower
	defending_mobs = list(
		/mob/living/basic/mining/ice_whelp,
		/mob/living/basic/mining/lobstrosity,
		/mob/living/basic/mining/legion/snow/spawner_made,
		/mob/living/basic/mining/ice_demon,
		/mob/living/basic/mining/wolf,
		/mob/living/simple_animal/hostile/asteroid/polarbear,
	)
	ore_vent_options = list(
		SMALL_VENT_TYPE = 3,
		MEDIUM_VENT_TYPE = 5,
		LARGE_VENT_TYPE = 7,
	)

/obj/structure/ore_vent/boss
	name = "menacing ore vent"
	desc = "An ore vent, brimming with underground ore. This one has an evil aura about it. Better be careful."
	unique_vent = TRUE
	spawn_drone_on_tap = FALSE
	boulder_size = BOULDER_SIZE_LARGE
	mineral_breakdown = list( // All the riches of the world, eeny meeny boulder room.
		/datum/material/iron = 1,
		/datum/material/glass = 1,
		/datum/material/plasma = 1,
		/datum/material/titanium = 1,
		/datum/material/silver = 1,
		/datum/material/gold = 1,
		/datum/material/diamond = 1,
		/datum/material/uranium = 1,
		/datum/material/bluespace = 1,
		/datum/material/plastic = 1,
	)
	defending_mobs = list(
		/mob/living/simple_animal/hostile/megafauna/bubblegum,
		/mob/living/simple_animal/hostile/megafauna/dragon,
		/mob/living/simple_animal/hostile/megafauna/colossus,
	)
	excavation_warning = "Something big is nearby. Are you ABSOLUTELY ready to excavate this ore vent? A NODE drone will be deployed after threat is neutralized."
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
		if(/mob/living/simple_animal/hostile/megafauna/wendigo/noportal)
			boss_string = "A chilling skull"
	. += span_notice("[boss_string] is etched onto the side of the vent.")

/obj/structure/ore_vent/boss/start_wave_defense()
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		return
	// Completely override the normal wave defense, and just spawn the boss.
	var/mob/living/simple_animal/hostile/megafauna/boss = new summoned_boss(loc)
	RegisterSignal(boss, COMSIG_LIVING_DEATH, PROC_REF(handle_wave_conclusion))
	SSblackbox.record_feedback("tally", "ore_vent_mobs_spawned", 1, summoned_boss)
	COOLDOWN_START(src, wave_cooldown, INFINITY) //Basically forever
	boss.say(boss.summon_line) //Pull their specific summon line to say. Default is meme text so make sure that they have theirs set already.

/obj/structure/ore_vent/boss/handle_wave_conclusion()
	node = new /mob/living/basic/node_drone(loc) //We're spawning the vent after the boss dies, so the player can just focus on the boss.
	SSblackbox.record_feedback("tally", "ore_vent_mobs_killed", 1, summoned_boss)
	COOLDOWN_RESET(src, wave_cooldown)
	return ..()

/obj/structure/ore_vent/boss/icebox
	icon_state = "ore_vent_ice"
	icon_state_tapped = "ore_vent_ice_active"
	defending_mobs = list(
		/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner,
		/mob/living/simple_animal/hostile/megafauna/wendigo/noportal,
		/mob/living/simple_animal/hostile/megafauna/colossus,
	)

#undef MAX_ARTIFACT_ROLL_CHANCE
#undef MINERAL_TYPE_OPTIONS_RANDOM
#undef OVERLAY_OFFSET_START
#undef OVERLAY_OFFSET_EACH
#undef MINERALS_PER_BOULDER
