/obj/docking_port/mobile/arrivals
	name = "arrivals shuttle"
	shuttle_id = "arrival"

	dir = WEST
	port_direction = SOUTH

	callTime = INFINITY
	ignitionTime = 5 SECONDS

	movement_force = list("KNOCKDOWN" = 3, "THROW" = 0)

	var/sound_played
	var/damaged //too damaged to undock?
	var/list/areas //areas in our shuttle
	var/list/queued_announces //people coming in that we have to announce
	var/obj/machinery/requests_console/console
	var/force_depart = FALSE
	var/perma_docked = FALSE //highlander with RESPAWN??? OH GOD!!!
	var/obj/docking_port/stationary/target_dock  // for badminry

/obj/docking_port/mobile/arrivals/Initialize(mapload)
	. = ..()
	preferred_direction = dir
	return INITIALIZE_HINT_LATELOAD //for latejoin list

/obj/docking_port/mobile/arrivals/register()
	..()
	if(SSshuttle.arrivals)
		log_mapping("More than one arrivals docking_port placed on map! Ignoring duplicates.")
	SSshuttle.arrivals = src

/obj/docking_port/mobile/arrivals/LateInitialize()
	areas = list()

	var/list/new_latejoin = list()
	for(var/area/shuttle/arrival/arrival_area in GLOB.areas)
		for (var/list/zlevel_turfs as anything in arrival_area.get_zlevel_turf_lists())
			for(var/turf/arrival_turf as anything in zlevel_turfs)
				for(var/obj/structure/chair/shuttle_chair in arrival_turf)
					new_latejoin += shuttle_chair
				if(isnull(console))
					console = locate() in arrival_turf
		areas += arrival_area

	if(SSjob.latejoin_trackers.len)
		log_mapping("Map contains predefined latejoin spawn points and an arrivals shuttle. Using the arrivals shuttle.")

	if(!new_latejoin.len)
		log_mapping("Arrivals shuttle contains no chairs for spawn points. Reverting to latejoin landmarks.")
		if(!SSjob.latejoin_trackers.len)
			log_mapping("No latejoin landmarks exist. Players will spawn unbuckled on the shuttle.")
		return

	SSjob.latejoin_trackers = new_latejoin

/obj/docking_port/mobile/arrivals/check()
	. = ..()

	if(perma_docked)
		if(mode != SHUTTLE_CALL)
			sound_played = FALSE
			mode = SHUTTLE_IDLE
		else
			SendToStation()
		return

	if(damaged)
		if(!CheckTurfsPressure())
			damaged = FALSE
			if(console)
				console.say("Repairs complete, launching soon.")
		return

//If this proc is high on the profiler add a cooldown to the stuff after this line

	else if(CheckTurfsPressure())
		damaged = TRUE
		if(console)
			console.say("Alert, hull breach detected!")
		aas_config_announce(/datum/aas_config_entry/arrivals_broken, list(), command_span=TRUE)
		if(mode != SHUTTLE_CALL)
			sound_played = FALSE
			mode = SHUTTLE_IDLE
		else
			SendToStation()
		return

	var/found_awake = PersonCheck() || NukeDiskCheck()
	if(mode == SHUTTLE_CALL)
		if(found_awake)
			SendToStation()
	else if(mode == SHUTTLE_IGNITING)
		if(found_awake && !force_depart)
			mode = SHUTTLE_IDLE
			sound_played = FALSE
		else if(!sound_played)
			hyperspace_sound(HYPERSPACE_WARMUP, areas)
			sound_played = TRUE
	else if(!found_awake)
		Launch(FALSE)

/obj/docking_port/mobile/arrivals/proc/CheckTurfsPressure()
	for(var/I in SSjob.latejoin_trackers)
		var/turf/open/T = get_turf(I)
		var/pressure = T.air.return_pressure()
		if(pressure < HAZARD_LOW_PRESSURE || pressure > HAZARD_HIGH_PRESSURE) //simple safety check
			return TRUE
	return FALSE

/obj/docking_port/mobile/arrivals/proc/PersonCheck()
	for(var/mob/player as anything in GLOB.player_list)
		if((get_area(player) in areas) && (player.stat != DEAD) && !HAS_TRAIT(player, TRAIT_BLOCK_SHUTTLE_MOVEMENT))
			return TRUE
	return FALSE

/obj/docking_port/mobile/arrivals/proc/NukeDiskCheck()
	for (var/obj/item/disk/nuclear/N in SSpoints_of_interest.real_nuclear_disks)
		if (get_area(N) in areas)
			return TRUE
	return FALSE

/obj/docking_port/mobile/arrivals/proc/SendToStation()
	var/dockTime = CONFIG_GET(number/arrivals_shuttle_dock_window)
	if(mode == SHUTTLE_CALL && timeLeft(1) > dockTime)
		if(console)
			console.say(damaged ? "Initiating emergency docking for repairs!" : "Now approaching: [station_name()].")
		hyperspace_sound(HYPERSPACE_LAUNCH, areas) //for the new guy
		setTimer(dockTime)

/obj/docking_port/mobile/arrivals/initiate_docking(obj/docking_port/stationary/S1, force=FALSE)
	var/docked = S1 == assigned_transit
	sound_played = FALSE
	if(docked) //about to launch
		if(!force_depart)
			var/cancel_reason
			if(PersonCheck())
				cancel_reason = "lifeform dectected on board"
			else if(NukeDiskCheck())
				cancel_reason = "critical station device detected on board"
			if(cancel_reason)
				mode = SHUTTLE_IDLE
				if(console)
					console.say("Launch cancelled, [cancel_reason].")
				return
		force_depart = FALSE
	. = ..()
	if(!. && !docked && !damaged)
		if(console)
			console.say("Welcome to your new life, employees!")
		for(var/L in queued_announces)
			var/datum/callback/C = L
			C.Invoke()
		LAZYCLEARLIST(queued_announces)

/obj/docking_port/mobile/arrivals/check_effects()
	..()
	if(mode == SHUTTLE_CALL && !sound_played && timeLeft(1) <= HYPERSPACE_END_TIME)
		sound_played = TRUE
		hyperspace_sound(HYPERSPACE_END, areas)

/obj/docking_port/mobile/arrivals/canDock(obj/docking_port/stationary/S)
	. = ..()
	if(. == SHUTTLE_ALREADY_DOCKED)
		. = SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/arrivals/proc/Launch(pickingup)
	if(pickingup)
		force_depart = TRUE
	if(mode == SHUTTLE_IDLE)
		if(console)
			console.say(pickingup ? "Departing immediately for new employee pickup." : "Shuttle departing.")
		var/obj/docking_port/stationary/target = target_dock
		if(QDELETED(target))
			target = SSshuttle.getDock("arrival_stationary")
		request(target) //we will intentionally never return SHUTTLE_ALREADY_DOCKED

/obj/docking_port/mobile/arrivals/proc/RequireUndocked(mob/user)
	if(mode == SHUTTLE_CALL || damaged)
		return

	Launch(TRUE)

	to_chat(user, span_notice("Calling your shuttle. One moment..."))
	while(mode != SHUTTLE_CALL && !damaged)
		stoplag()

/**
 * Queues an announcement arrival.
 *
 * Arguments:
 * * mob - The arriving mob.
 * * rank - The job of the arriving mob.
 */
/obj/docking_port/mobile/arrivals/proc/QueueAnnounce(mob, rank)
	if(mode != SHUTTLE_CALL)
		announce_arrival(mob, rank)
	else
		LAZYADD(queued_announces, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(announce_arrival), mob, rank))

/obj/docking_port/mobile/arrivals/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, perma_docked))
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("arrivals shuttle", "[var_value ? "stopped" : "started"]"))
	return ..()
