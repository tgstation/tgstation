// These are supposed to be discrete effects so we can tell at a glance what does each override
// of [/datum/sm_delam_strat/proc/delaminate] does.
// Please keep them discrete and give them proper, descriptive function names.
// Oh and all of them returns true if the effect succeeded.

/// Irradiates mobs around 20 tiles of the sm.
/// Just the mobs apparently.
/datum/sm_delam_strat/proc/effect_irradiate(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for (var/mob/living/victim in range(20, sm))
		if(victim.z != sm_turf.z)
			continue
		SSradiation.irradiate(victim)
	return TRUE

/// Hallucinates and makes mobs in Z level sad.
/datum/sm_delam_strat/proc/effect_demoralize(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		if(!istype(victim) || victim.z != sm_turf.z)
			continue
		if(ishuman(victim))
			//Hilariously enough, running into a closet should make you get hit the hardest.
			var/mob/living/carbon/human/human = victim
			human.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(victim, src) + 1)) ) )

	for(var/mob/victim as anything in GLOB.player_list)
		var/turf/mob_turf = get_turf(victim)
		if(sm_turf.z != mob_turf.z)
			continue
		SEND_SOUND(victim, 'sound/magic/charge.ogg')
		if (victim.z != sm_turf.z)
			to_chat(victim, span_boldannounce("You hold onto \the [victim.loc] as hard as you can, as reality distorts around you. You feel safe."))
			continue
		to_chat(victim, span_boldannounce("You feel reality distort for a moment..."))
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam)
	return TRUE

/// Spawns anomalies all over the station. Half instantly, the other half over time.
/datum/sm_delam_strat/proc/effect_anomaly(obj/machinery/power/supermatter_crystal/sm)
	var/anomalies = 10
	var/list/anomaly_types = list(GRAVITATIONAL_ANOMALY = 55, HALLUCINATION_ANOMALY = 45, DELIMBER_ANOMALY = 35, FLUX_ANOMALY = 25, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns

	// Spawns this many anomalies instantly. Spawns the rest with callbacks.
	var/cutoff_point = round(anomalies * 0.5, 1)

	for(var/i in 1 to anomalies)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)
		
		if(i < cutoff_point)
			supermatter_anomaly_gen(anomaly_location, anomaly_to_spawn, has_changed_lifespan = FALSE)
			continue

		var/current_spawn = rand(5 SECONDS, 10 SECONDS)
		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(DT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(src, /proc/supermatter_anomaly_gen, anomaly_location, anomaly_to_spawn, TRUE), current_spawn + extended_spawn)
	return TRUE

/// Explodes
/datum/sm_delam_strat/proc/effect_explosion(obj/machinery/power/supermatter_crystal/sm)
	var/explosion_power = sm.explosion_power
	var/power_scaling = sm.gasmix_power_ratio
	var/turf/sm_turf = get_turf(sm)
	//Dear mappers, balance the sm max explosion radius to 17.5, 37, 39, 41
	explosion(origin = sm_turf,
		devastation_range = explosion_power * max(power_scaling, 0.205) * 0.5,
		heavy_impact_range = explosion_power * max(power_scaling, 0.205) + 2,
		light_impact_range = explosion_power * max(power_scaling, 0.205) + 4,
		flash_range = explosion_power * max(power_scaling, 0.205) + 6,
		adminlog = TRUE,
		ignorecap = TRUE
	)
	return TRUE

/// Explodes
/datum/sm_delam_strat/proc/effect_singulo(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		stack_trace("Supermatter [sm] failed to spawn singularity, cant get current turf.")
		return FALSE
	var/obj/singularity/created_singularity = new(sm_turf)
	created_singularity.energy = 800
	created_singularity.consume(src)
	return TRUE

/// Teslas
/datum/sm_delam_strat/proc/effect_tesla(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		stack_trace("Supermatter [sm] failed to spawn tesla, cant get current turf.")
		return FALSE
	var/obj/energy_ball/created_tesla = new(sm_turf)
	created_tesla.energy = 200 //Gets us about 9 balls
	return TRUE

/// Mail the shuttle off to buy milk.
/datum/sm_delam_strat/proc/effect_strand_shuttle()
	set waitfor = FALSE
	// set timer to infinity, so shuttle never arrives
	SSshuttle.emergency.setTimer(INFINITY)
	// disallow shuttle recalls, so people cannot cheese the timer
	SSshuttle.emergency_no_recall = TRUE
	// set supermatter cascade to true, to prevent auto evacuation due to no way of calling the shuttle
	SSshuttle.supermatter_cascade = TRUE
	// set hijack completion timer to infinity, so that you cant prematurely end the round with a hijack
	for(var/obj/machinery/computer/emergency_shuttle/console in GLOB.machines)
		console.hijack_completion_flight_time_set = INFINITY

	/* This logic is to keep uncalled shuttles uncalled
	In SSshuttle, there is not much of a way to prevent shuttle calls, unless we mess with admin panel vars
	SHUTTLE_STRANDED is different here, because it *can* block the shuttle from being called, however if we don't register a hostile
	environment, it gets unset immediately. Internally, it checks if the count of HEs is zero
	and that the shuttle is in stranded mode, then frees it with an announcement.
	This is a botched solution to a problem that could be solved with a small change in shuttle code, however-
	*/
	if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
		SSshuttle.emergency.mode = SHUTTLE_STRANDED
		SSshuttle.registerHostileEnvironment(src)
		return

	sleep(2 SECONDS)

	// say goodbye to that shuttle of yours
	if(SSshuttle.emergency.mode != SHUTTLE_ESCAPE)
		priority_announce("Fatal error occurred in emergency shuttle uplink during transit. Unable to reestablish connection.",
			"Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')
	else
	// except if you are on it already, then you are safe c:
		minor_announce("ERROR: Corruption detected in navigation protocols. Connection with Transponder #XCC-P5831-ES13 lost. \
				Backup exit route protocol decrypted. Calibrating route...",
			"Emergency Shuttle", TRUE) // wait out until the rift on the station gets destroyed and the final message plays
		var/list/mobs = mobs_in_area_type(list(/area/shuttle/escape))
		for(var/mob/living/mob as anything in mobs) // emulate mob/living/lateShuttleMove() behaviour
			if(mob.buckled)
				continue
			if(mob.client)
				shake_camera(mob, 3 SECONDS * 0.25, 1)
			mob.Paralyze(3 SECONDS, TRUE)

/datum/sm_delam_strat/proc/effect_cascade_demoralize()
	for(var/mob/player as anything in GLOB.player_list)
		if(!isdead(player))
			to_chat(player, span_boldannounce("Everything around you is resonating with a powerful energy. This can't be good."))
			SEND_SIGNAL(player, COMSIG_ADD_MOOD_EVENT, "cascade", /datum/mood_event/cascade)
		SEND_SOUND(player, 'sound/magic/charge.ogg')

/datum/sm_delam_strat/proc/effect_emergency_state()
	if(SSsecurity_level.get_current_level_as_number() != SEC_LEVEL_DELTA)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA) // skip the announcement and shuttle timer adjustment in set_security_level()
	make_maint_all_access()
	for(var/obj/machinery/light/light_to_break in GLOB.machines)
		if(prob(35))
			light_to_break.set_major_emergency_light()
			continue
		light_to_break.break_light_tube()

/// Spawn an evacuation rift for people to go through.
/datum/sm_delam_strat/proc/effect_evac_rift()
	var/turf/rift_location = get_turf(pick(GLOB.generic_event_spawns))
	var/area/rift_area = get_area_name(rift_location)
	var/obj/cascade_portal/rift = new /obj/cascade_portal(rift_location)

	message_admins("Exit rift created at [rift_area]. [ADMIN_JMP(rift_location)]")
	log_game("Bluespace Exit Rift was created at [rift_area].")
	rift.investigate_log("created at [rift_area].", INVESTIGATE_ENGINE)
	return rift

/// Scatters crystal mass over the event spawns as long as they are at least 30 tiles away from whatever we want to avoid.
/datum/sm_delam_strat/proc/effect_crystal_mass(obj/machinery/power/supermatter_crystal/sm, avoid)
	new /obj/crystal_mass(get_turf(sm))
	var/list/possible_spawns = GLOB.generic_event_spawns.Copy()
	for(var/i in 1 to rand(4,6))
		var/spawn_location
		do
			spawn_location = pick_n_take(possible_spawns)
		while(get_dist(spawn_location, avoid) < 30)
		new /obj/crystal_mass(get_turf(spawn_location))
