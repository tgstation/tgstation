///Earthquake event
///Breaks shit
/datum/round_event_control/earthquake
	name = "Planetary Earthquake" //change name
	description = "After a brief warning, creates a large tear in the structure of the station."
	typepath = /datum/round_event/earthquake
	category = EVENT_CATEGORY_ENGINEERING
	min_players = 15
	max_occurrences = 3
	earliest_start = 35 MINUTES
	weight = 6
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 7
	map_flags = EVENT_PLANETARY_ONLY

/datum/round_event_control/earthquake/can_spawn_event(players_amt, allow_magic)
	. = ..()
	if(!.)
		return .

	if(!length(GLOB.generic_event_spawns))
		return FALSE

/datum/round_event/earthquake
	start_when = 1
	announce_when = 3
	end_when = 25
	announce_chance = 25
	///The chosen location and center of our earthquake.
	var/turf/epicenter
	///A list of turfs that will be damaged by this event.
	var/list/turfs_to_shred
	///A list of turfs directly under turfs_to_shred, for creating a proper chasm to the floor below.
	var/list/underbelly = list()

/datum/round_event/earthquake/setup()
	epicenter = get_turf(pick(GLOB.generic_event_spawns))
	if(!epicenter)
		message_admins("Earthquake event failed to find a turf! generic_event_spawn landmarks may be absent or bugged. Aborting...")
		return

	message_admins("An earthquake is about to strike the [get_area_name(epicenter)] at [ADMIN_JMP(epicenter)].")

	///Picks two points generally opposite from each other
	var/turf/fracture_point_high = locate(epicenter.x + rand(3, 7), epicenter.y + rand(3, 7), epicenter.z)

	var/turf/fracture_point_low = locate(epicenter.x - rand(3, 7), epicenter.y - rand(3, 7), epicenter.z)

	turfs_to_shred = block(fracture_point_high, fracture_point_low)

	///Grab a list of turfs below the ones we're going to destroy. If we're at the bottom layer, it will just tear up the flooring a bunch.
	for(var/turf/turf_to_quake in turfs_to_shred)
		underbelly += SSmapping.get_turf_below(turf_to_quake)

	///Filter out some of the points that are a certain distance away from two or more of the epicenter and fracture points.
	///This should create a pattern more akin to a line between two points, rather than a rectangle of destroyed ground.
	for(var/turf/turf_to_check in turfs_to_shred)
		var/total_distance = get_dist(turf_to_check, epicenter) + get_dist(turf_to_check, fracture_point_high) + get_dist(turf_to_check, fracture_point_low)
		if(total_distance > (get_dist(fracture_point_high, fracture_point_low) * 1.7))
			turfs_to_shred -= turf_to_check

/datum/round_event/earthquake/announce(fake)
	priority_announce("Planetary monitoring systems indicate a devastating seismic event in the near future.", "Seismic Report")

/datum/round_event/earthquake/start()
	notify_ghosts("The earthquake's epicenter has been located: [get_area_name(epicenter)]", source = epicenter, header = "Rumble Rumble Rumble!")

/datum/round_event/earthquake/tick()
	if(ISMULTIPLE(activeFor, 5))
		for(var/turf/turf_to_quake in turfs_to_shred)
			turf_to_quake.Shake(0.1, 0.1, 1 SECONDS)

	if(ISMULTIPLE(activeFor, 10))
		for(var/mob/earthquake_witness as anything in GLOB.player_list)
			if(!is_station_level(earthquake_witness.z))
				continue
			shake_camera(earthquake_witness, 1 SECONDS, 1 + (activeFor % 10))
			earthquake_witness.playsound_local(earthquake_witness, pick('sound/misc/earth_rumble_distant1.ogg', 'sound/misc/earth_rumble_distant2.ogg', 'sound/misc/earth_rumble_distant3.ogg', 'sound/misc/earth_rumble_distant4.ogg'), 100)

	if(activeFor == end_when - 2)
		for(var/turf/turf_to_quake in turfs_to_shred)
			turf_to_quake.Shake(0.3, 0.3, 1 SECONDS)
			for(var/mob/living/carbon/quake_victim in turf_to_quake)
				quake_victim.Knockdown(3 SECONDS)
				quake_victim.Paralyze(2 SECONDS)
				to_chat(quake_victim, span_warning("The ground quakes beneath you, throwing you off your feet!"))


	///If we're about to strike, we break up the floor a bit right before creating the chasm.
	if(activeFor == end_when - 1)
		for(var/turf/turf_to_shred in turfs_to_shred)
			if(prob(90))
				SSexplosions.lowturf += turf_to_shred
		for(var/turf/turf_to_shred in underbelly) //Theoretically this should clear out any rock/snow walls below, allowing stuff to fall properly.
			SSexplosions.lowturf += turf_to_shred

/datum/round_event/earthquake/end()
	playsound(epicenter, 'sound/misc/earth_rumble.ogg', 50)
	for(var/mob/earthquake_witness as anything in GLOB.player_list)
		if(!is_station_level(earthquake_witness.z) || !is_mining_level(earthquake_witness.z))
			continue
		shake_camera(earthquake_witness, 2 SECONDS, 4)
		earthquake_witness.playsound_local(earthquake_witness, 'sound/effects/explosionfar.ogg', 100)

	for(var/turf/turf_to_shred in turfs_to_shred)
		if(prob(10)) //Varies up the damage a little bit.
			SSexplosions.medturf += turf_to_shred
		else
			SSexplosions.highturf += turf_to_shred
