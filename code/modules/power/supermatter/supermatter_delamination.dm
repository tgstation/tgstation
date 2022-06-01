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
	SSshuttle.registerHostileEnvironment(src)
	SSshuttle.supermatter_cascade = TRUE
	call_explosion()
	create_cascade_ambience()
	pick_rift_location()
	warn_crew()
	new /obj/crystal_mass(supermatter_turf)
	for(var/i in 1 to rand(4,6))
		new /obj/crystal_mass(get_turf(pick(GLOB.generic_event_spawns)))

/**
 * Adds a bit of spiciness to the cascade by breaking lights and turning emergency maint access on
 */
/datum/supermatter_delamination/proc/create_cascade_ambience()
	break_lights_on_station()
	make_maint_all_access()

/**
 * Picks a random location for the rift
 */
/datum/supermatter_delamination/proc/pick_rift_location()
	var/turf/rift_location = get_turf(pick(GLOB.generic_event_spawns))
	cascade_rift = new /obj/cascade_portal(rift_location)
	RegisterSignal(cascade_rift, COMSIG_PARENT_QDELETING, .proc/deleted_portal)

/**
 * Warns the crew about the cascade start and the rift location
 */
/datum/supermatter_delamination/proc/warn_crew()
	for(var/mob/player as anything in GLOB.alive_player_list)
		to_chat(player, span_boldannounce("You feel a strange presence in the air around you. You feel unsafe."))

	priority_announce("Unknown harmonance affecting local spatial substructure, all nearby matter is starting to crystallize.", "Central Command Higher Dimensional Affairs", 'sound/misc/bloblarm.ogg')
	priority_announce("There's been a sector-wide electromagnetic pulse. All of our systems are heavily damaged, including those required for emergency shuttle navigation. \
		We can only reasonably conclude that a supermatter cascade has been initiated on or near your station. \
		Evacuation is no longer possible by conventional means; however, we managed to open a rift near the [get_area_name(cascade_rift)]. \
		All personnel are hereby advised to enter the rift using all means available. Retrieval of survivors will be conducted upon recovery of necessary facilities. \
		Good l\[\[###!!!-")


	addtimer(CALLBACK(src, .proc/delta), 10 SECONDS)

/datum/supermatter_delamination/proc/deleted_portal()
	SIGNAL_HANDLER

	priority_announce("The rift has been destroyed, we can no longer help you...", "Warning", 'sound/misc/bloblarm.ogg')

	addtimer(CALLBACK(src, .proc/last_message), 50 SECONDS)

	addtimer(CALLBACK(src, .proc/the_end), 1 MINUTES)

/**
 * Increases the security level to the highest level
 */
/datum/supermatter_delamination/proc/delta()
	set_security_level("delta")
	sound_to_playing_players('sound/misc/notice1.ogg')

/**
 * Announces the last message to the station
 */
/datum/supermatter_delamination/proc/last_message()
	priority_announce("To the remaining survivors of [station_name()], We're sorry.", " ", 'sound/misc/bloop.ogg')

/**
 * Ends the round
 */
/datum/supermatter_delamination/proc/the_end()
	SSticker.news_report = SUPERMATTER_CASCADE
	SSticker.force_ending = 1

/**
 * Break the lights on the station, have 35% of them be set to emergency
 */
/datum/supermatter_delamination/proc/break_lights_on_station()
	for(var/obj/machinery/light/light_to_break in GLOB.machines)
		if(prob(35))
			light_to_break.emergency_mode = TRUE
			light_to_break.update_appearance()
			continue
		light_to_break.break_light_tube()
