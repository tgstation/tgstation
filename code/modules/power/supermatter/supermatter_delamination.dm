#define MIN_RIFT_SAFE_DIST 30

/datum/supermatter_delamination
	///Power amount of the SM at the moment of death
	var/supermatter_power = 0
	///Amount of total gases interacting with the SM
	var/supermatter_gas_amount = 0
	///Base number of anomalies to spawn (can go up or down with a random small amount)
	var/anomalies_to_spawn = 10
	///Can we spawn anomalies after dealing with the delamination type?
	var/should_spawn_anomalies = TRUE
	///Reference to the supermatter turf
	var/turf/supermatter_turf
	///Baseline strenght of the explosion caused by the SM
	var/supermatter_explosion_power = 0
	///Amount the gasmix will affect the explosion size
	var/supermatter_gasmix_power_ratio = 0
	///Are we triggering a supermatter cascade?
	var/supermatter_cascade = FALSE
	///The rift in space that will be created by the cascade
	var/obj/cascade_portal/cascade_rift

/datum/supermatter_delamination/New(supermatter_power, supermatter_gas_amount, turf/supermatter_turf, supermatter_explosion_power, supermatter_gasmix_power_ratio, can_spawn_anomalies, supermatter_cascade)
	. = ..()

	src.supermatter_power = supermatter_power
	src.supermatter_gas_amount = supermatter_gas_amount
	src.supermatter_turf = supermatter_turf
	src.supermatter_explosion_power = supermatter_explosion_power
	src.supermatter_gasmix_power_ratio = supermatter_gasmix_power_ratio

	if(supermatter_cascade)
		start_supermatter_cascade()
		return

	setup_mob_interaction()
	setup_delamination_type()

	if(!should_spawn_anomalies || !can_spawn_anomalies)
		qdel(src)
		return

	setup_anomalies()

/**
 * What the mobs should deal with when a delamination happens
 */
/datum/supermatter_delamination/proc/setup_mob_interaction()
	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		if(!istype(victim) || victim.z != supermatter_turf.z)
			continue

		if(ishuman(victim))
			//Hilariously enough, running into a closet should make you get hit the hardest.
			var/mob/living/carbon/human/human = victim
			human.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(victim, src) + 1)) ) )

		if (get_dist(victim, src) <= DETONATION_RADIATION_RANGE)
			SSradiation.irradiate(victim)

	for(var/mob/victim as anything in GLOB.player_list)
		var/turf/mob_turf = get_turf(victim)
		if(supermatter_turf.z != mob_turf.z)
			continue

		SEND_SOUND(victim, 'sound/magic/charge.ogg')

		if (victim.z != supermatter_turf.z)
			to_chat(victim, span_boldannounce("You hold onto \the [victim.loc] as hard as you can, as reality distorts around you. You feel safe."))
			continue

		to_chat(victim, span_boldannounce("You feel reality distort for a moment..."))
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam)

/**
 * Setup for the types of possible delaminations and their effects (singulo, tesla or normal)
 */
/datum/supermatter_delamination/proc/setup_delamination_type()
	if(supermatter_gas_amount > MOLE_PENALTY_THRESHOLD)
		call_singulo()
		return
	if(supermatter_power > POWER_PENALTY_THRESHOLD)
		call_tesla()
		return

	call_explosion()

/**
 * Spawns the singularity
 */
/datum/supermatter_delamination/proc/call_singulo()
	if(!supermatter_turf) //If something fucks up we blow anyhow. This fix is 4 years old and none ever said why it's here. help.
		call_explosion()
		return
	var/obj/singularity/created_singularity = new(supermatter_turf)
	created_singularity.energy = 800
	created_singularity.consume(src)
	should_spawn_anomalies = FALSE

/**
 * Spawns the tesla
 */
/datum/supermatter_delamination/proc/call_tesla()
	if(supermatter_turf)
		var/obj/energy_ball/created_tesla = new(supermatter_turf)
		created_tesla.energy = 200 //Gets us about 9 balls
	call_explosion()
	should_spawn_anomalies = FALSE

/**
 * Spawns the explosion
 */
/datum/supermatter_delamination/proc/call_explosion()
	//Dear mappers, balance the sm max explosion radius to 17.5, 37, 39, 41
	explosion(origin = supermatter_turf,
		devastation_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) * 0.5,
		heavy_impact_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 2,
		light_impact_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 4,
		flash_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 6,
		adminlog = TRUE,
		ignorecap = TRUE
	)

/**
 * Setups how many anomalies to spawn
 */
/datum/supermatter_delamination/proc/setup_anomalies()
	anomalies_to_spawn = max(round(0.004 * supermatter_power, 1) + rand(-2, 2), 1)
	spawn_anomalies()

/**
 * Spawns the first half anomalies instantly and calls the second half
 */
/datum/supermatter_delamination/proc/spawn_anomalies()
	var/list/anomaly_types = list(GRAVITATIONAL_ANOMALY = 55, HALLUCINATION_ANOMALY = 45, DELIMBER_ANOMALY = 35, FLUX_ANOMALY = 25, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns
	var/currently_spawning_anomalies = round(anomalies_to_spawn * 0.5, 1)
	anomalies_to_spawn -= currently_spawning_anomalies
	for(var/i in 1 to currently_spawning_anomalies)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)
		supermatter_anomaly_gen(anomaly_location, anomaly_to_spawn, has_changed_lifespan = FALSE)

	spawn_overtime()

/**
 * Spawns the second half anomalies after a delay
 */
/datum/supermatter_delamination/proc/spawn_overtime()

	var/list/anomaly_types = list(GRAVITATIONAL_ANOMALY = 55, HALLUCINATION_ANOMALY = 45, DELIMBER_ANOMALY = 35, FLUX_ANOMALY = 25, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns

	var/current_spawn = rand(5 SECONDS, 10 SECONDS)
	for(var/i in 1 to anomalies_to_spawn)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)
		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(DT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(src, .proc/spawn_anomaly, anomaly_location, anomaly_to_spawn), current_spawn + extended_spawn)
		current_spawn += next_spawn

/**
 * Callback for the anomalies to spawn after some time
 */
/datum/supermatter_delamination/proc/spawn_anomaly(location, type)
	supermatter_anomaly_gen(location, type, has_changed_lifespan = FALSE)

/**
 * Setup for the cascade delamination
 */
/datum/supermatter_delamination/proc/start_supermatter_cascade()
	SSshuttle.emergency.setTimer(INFINITY)
	SSshuttle.emergency_no_recall = TRUE
	SSshuttle.supermatter_cascade = TRUE
	if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
		SSshuttle.emergency.mode = SHUTTLE_STRANDED
		SSshuttle.registerHostileEnvironment(src)

	for(var/mob/player as anything in GLOB.player_list)
		if(!isobserver(player))
			to_chat(player, span_boldannounce("Everything around you is resonating with a powerful energy. This can't be good."))
			SEND_SIGNAL(player, COMSIG_ADD_MOOD_EVENT, "cascade", /datum/mood_event/cascade)
		SEND_SOUND(player, 'sound/magic/charge.ogg')

	call_explosion()
	create_cascade_ambience()
	warn_crew()
	var/rift_loc = pick_rift_location()
	new /obj/crystal_mass(supermatter_turf)

	var/list/mass_loc_candidates = GLOB.generic_event_spawns
	mass_loc_candidates.Remove(rift_loc) // this should now actually get rid of stalemates
	for(var/i in 1 to rand(4,6))
		var/mass_loc
		do
			mass_loc = pick_n_take(mass_loc_candidates)
		while(get_dist(mass_loc, rift_loc) < MIN_RIFT_SAFE_DIST)
		new /obj/crystal_mass(get_turf(mass_loc))

/**
 * Adds a bit of spiciness to the cascade by breaking lights and turning emergency maint access on
 */
/datum/supermatter_delamination/proc/create_cascade_ambience()
	if(SSsecurity_level.current_level != SEC_LEVEL_DELTA)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA) // skip the announcement and shuttle timer adjustment
	break_lights_on_station()
	make_maint_all_access()

/**
 * Picks a random location for the rift
 * Returns: ref to eve
 */
/datum/supermatter_delamination/proc/pick_rift_location()
	var/rift_spawn = pick(GLOB.generic_event_spawns)
	var/turf/rift_turf = get_turf(rift_spawn)
	cascade_rift = new /obj/cascade_portal(rift_turf)
	message_admins("Exit rift created at [get_area_name(rift_turf)]. [ADMIN_JMP(cascade_rift)]")
	log_game("Bluespace Exit Rift was created at [get_area_name(rift_turf)].")
	cascade_rift.investigate_log("created at [get_area_name(rift_turf)].", INVESTIGATE_ENGINE)
	RegisterSignal(cascade_rift, COMSIG_PARENT_QDELETING, .proc/deleted_portal)
	return rift_spawn

/**
 * Warns the crew about the cascade start and the rift location
 */
/datum/supermatter_delamination/proc/warn_crew()
	priority_announce("A Type-C resonance shift event has occurred in your sector. Scans indicate local oscillation flux affecting spatial and gravitational substructure. \
		Multiple resonance hotspots have formed. Please standby.", "Nanotrasen Star Observation Association", ANNOUNCER_SPANOMALIES)

	if(SSshuttle.emergency.mode != SHUTTLE_STRANDED)
		addtimer(CALLBACK(src, .proc/announce_shuttle_gone), 2 SECONDS)

	addtimer(CALLBACK(src, .proc/announce_beginning), 5 SECONDS)

/datum/supermatter_delamination/proc/deleted_portal()
	SIGNAL_HANDLER
	message_admins("[cascade_rift] deleted at [get_area_name(cascade_rift.loc)]. [ADMIN_JMP(cascade_rift.loc)]")
	log_game("[cascade_rift] was deleted.")
	cascade_rift.investigate_log("was deleted.", INVESTIGATE_ENGINE)

	priority_announce("[Gibberish("The rift has been destroyed, we can no longer help you.", FALSE, 5)]")

	addtimer(CALLBACK(src, .proc/announce_gravitation_shift), 25 SECONDS)
	addtimer(CALLBACK(src, .proc/last_message), 50 SECONDS)
	if(SSshuttle.emergency.mode != SHUTTLE_ESCAPE) // if the shuttle is enroute to centcom, we let the shuttle end the round
		addtimer(CALLBACK(src, .proc/the_end), 1 MINUTES)

// this function is for flavor and to let people know that we reached the halfway point
/datum/supermatter_delamination/proc/announce_gravitation_shift()
	priority_announce("Reports indicate formation of crystalline seeds following resonance shift event. \
		Rapid expansion of crystal mass proportional to rising gravitational force. \
		Matter collapse due to gravitational pull likely.",
		"Nanotrasen Star Observation Association")

/datum/supermatter_delamination/proc/announce_shuttle_gone()
	// say goodbye to that shuttle of yours
	if(SSshuttle.emergency.mode != SHUTTLE_ESCAPE)
		priority_announce("Fatal error occurred in emergency shuttle uplink during transit. Unable to reestablish connection.",
			"Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')
	else
	// except if you are on it already, then you are safe c:
		minor_announce("ERROR: Corruption detected in navigation protocols. Connection with Transponder #XCC-P5831-ES13 lost. \
				Backup exit route protocol decrypted. Calibrating route...",
			"Emergency Shuttle", TRUE) // wait out until the rift on the station gets destroyed and the final message plays
		var/list/shuttle_areas = list(/area/shuttle/escape)
		var/list/mobs = mobs_in_area_type(shuttle_areas)
		for(var/mob/living/mob as anything in mobs)
			if(mob.client)
				shake_camera(mob, 3 SECONDS * 0.25, 1) // properly emulate lateShuttleMove() behaviour
			mob.Paralyze(3 SECONDS, TRUE)

/**s
 * Announces the last message to the station, frees the shuttle from purgatory if applicable
 */
/datum/supermatter_delamination/proc/last_message()
	priority_announce("[Gibberish("All attempts at evacuation have now ceased, and all assets have been retrieved from your sector.\n \
		To the remaining survivors of [station_name()], farewell.", FALSE, 5)]")

	if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
		minor_announce("Navigation protocol set to backup route. Reorienting bluespace vessel to exit vector. ETA 15 seconds.",
			"Emergency Shuttle", TRUE)
		SSshuttle.emergency.setTimer(15 SECONDS)
		SSticker.news_report = SUPERMATTER_CASCADE

/**
 * Announce detail about the event, as well as rift location
 */
/datum/supermatter_delamination/proc/announce_beginning()
	priority_announce("We have been hit by a sector-wide electromagnetic pulse. All of our systems are heavily damaged, including those \
		required for shuttle navigation. We can only reasonably conclude that a supermatter cascade is occurring on or near your station.\n\n\
		Evacuation is no longer possible by conventional means; however, we managed to open a rift near the [get_area_name(cascade_rift)]. \
		All personnel are hereby required to enter the rift by any means available.\n\n\
		[Gibberish("Retrieval of survivors will be conducted upon recovery of necessary facilities.", FALSE, 5)] \
		[Gibberish("Good luck--", FALSE, 25)]")

/proc/mobs_in_area_type(list/area/checked_areas)
	var/list/mobs_in_area = list()
	for(var/mob/living/mob as anything in GLOB.mob_living_list)
		if(QDELETED(mob))
			continue
		for(var/area as anything in checked_areas)
			if(istype(get_area(mob), area))
				mobs_in_area += mob
				break
	return mobs_in_area

/**
 * Ends the round
 */
/datum/supermatter_delamination/proc/the_end()
	SSticker.news_report = SUPERMATTER_CASCADE
	SSticker.force_ending = TRUE

/**
 * Break the lights on the station, have 35% of them be set to emergency
 */
/datum/supermatter_delamination/proc/break_lights_on_station()
	for(var/obj/machinery/light/light_to_break in GLOB.machines)
		if(prob(35))
			light_to_break.set_cascade_light()
			continue
		light_to_break.break_light_tube()

#undef MIN_RIFT_SAFE_DIST
