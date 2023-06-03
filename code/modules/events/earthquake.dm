///Earthquake random event.
///Draws a line of turfs between a high and low point. These turfs will shake and eventually "collapse", forming a deep cut in the station that drops to the z-level below.
///Much of the actual structural damage is done through the explosions subsystem. Objects, machines, and especially people
///that aren't moved out of the impact area (indicated by the wobbly tiles) will not just be thrown down a z-level, but also be destroyed/maimed in the process.
///This event uses generic_event_spawn landmarks which are located in public areas/workplaces, making it not only structurally devastating but also incredibly disruptive.
///Weight should generally be on-par with that of a meteor storm or rod, since it's somewhere between the two in terms of targeted destructive power.
/datum/round_event_control/earthquake
	name = "Chasmic Earthquake"
	description = "After a brief warning, creates a large chasm in the structure of the station, demolishing anything caught in the fault."
	typepath = /datum/round_event/earthquake
	category = EVENT_CATEGORY_ENGINEERING
	min_players = 20
	max_occurrences = 3
	earliest_start = 35 MINUTES
	weight = 7
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

	// Give a bit of variance so our epicenter isn't always on the landmark.
	epicenter = locate(epicenter.x + rand(-10, 10), epicenter.y + rand(-10, 10), epicenter.z)

	message_admins("An earthquake event is about to strike the [get_area_name(epicenter)][ADMIN_JMP(epicenter)].")

	// Picks two points generally opposite from each other
	var/turf/fracture_point_high = locate(epicenter.x + rand(3, 8), epicenter.y + rand(3, 8), epicenter.z)

	var/turf/fracture_point_low = locate(epicenter.x - rand(3, 8), epicenter.y - rand(3, 8), epicenter.z)

	turfs_to_shred = block(fracture_point_high, fracture_point_low)

	// Filter out some of the points that are a certain distance away from the epicenter/fracture points.
	// This should create a pattern more akin to a fracture in the ground, rather than a rectangle-shaped crater of destroyed ground.
	for(var/turf/turf_to_check in turfs_to_shred)
		var/total_distance = get_dist(turf_to_check, epicenter) + get_dist(turf_to_check, fracture_point_high) + get_dist(turf_to_check, fracture_point_low)
		if(total_distance > (get_dist(fracture_point_high, fracture_point_low) * 1.5))
			turfs_to_shred -= turf_to_check

	// Grab a list of turfs below the ones we're going to destroy.
	// If we're at the bottom layer, it will just tear up the flooring a bunch (exposing it to LAVA).
	for(var/turf/turf_to_quake in turfs_to_shred)
		underbelly += SSmapping.get_turf_below(turf_to_quake)

/datum/round_event/earthquake/announce(fake)
	priority_announce("Planetary monitoring systems indicate a devastating seismic event in the near future.", "Seismic Report")

/datum/round_event/earthquake/start()
	notify_ghosts("The earthquake's epicenter has been located: [get_area_name(epicenter)]!", source = epicenter, header = "Rumble Rumble Rumble!")

/datum/round_event/earthquake/tick()
	if(ISMULTIPLE(activeFor, 5))
		for(var/turf/turf_to_quake in turfs_to_shred)
			turf_to_quake.Shake(0.1, 0.1, 1 SECONDS)

		if(ISMULTIPLE(activeFor, 10))
			for(var/mob/earthquake_witness as anything in GLOB.player_list)
				if(!is_station_level(earthquake_witness.z))
					continue
				shake_camera(earthquake_witness, 1 SECONDS, 1 + (activeFor % 10))
				earthquake_witness.playsound_local(earthquake_witness, pick('sound/misc/earth_rumble_distant1.ogg', 'sound/misc/earth_rumble_distant2.ogg', 'sound/misc/earth_rumble_distant3.ogg', 'sound/misc/earth_rumble_distant4.ogg'), 75)

	if(activeFor == end_when - 2)
		for(var/turf/turf_to_quake in turfs_to_shred)
			turf_to_quake.Shake(0.5, 0.5, 1 SECONDS)
			for(var/mob/living/carbon/quake_victim in turf_to_quake)
				quake_victim.Knockdown(3 SECONDS)
				quake_victim.Paralyze(3 SECONDS)
				if(quake_victim.client)
					quake_victim.client.give_award(/datum/award/achievement/misc/earthquake_victim, quake_victim)
				to_chat(quake_victim, span_warning("The ground quakes beneath you, throwing you off your feet!"))

		for(var/turf/turf_to_quake in underbelly)
			turf_to_quake.Shake(0.5, 0.5, 1 SECONDS)
			for(var/mob/living/carbon/quake_victim in turf_to_quake)
				to_chat(quake_victim, span_warning("Damn, I wonder what that rumbling noise is?")) ///You're about to find out
				quake_victim.playsound_local(quake_victim, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE) //get a better noise

	// Step one of the destruction, which wrecks the turfs in the "underbelly" of the earthquake zone.
	// This should clear out any rock/snow walls below, allowing a proper chasm to form if the underbelly area isn't clear.
	// If not it just causes light structural damage and injures people underneath.
	if(activeFor == end_when - 1)
		for(var/turf/turf_to_shred in turfs_to_shred)
			if(prob(90))
				SSexplosions.lowturf += turf_to_shred
		for(var/turf/turf_to_shred in underbelly)
			SSexplosions.lowturf += turf_to_shred
		playsound(epicenter, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE) //get a better noise

/datum/round_event/earthquake/end()
	playsound(epicenter, 'sound/misc/earth_rumble.ogg', 100)
	for(var/mob/earthquake_witness as anything in GLOB.player_list)
		if(!is_station_level(earthquake_witness.z) || !is_mining_level(earthquake_witness.z))
			continue
		shake_camera(earthquake_witness, 2 SECONDS, 4)
		earthquake_witness.playsound_local(earthquake_witness, 'sound/effects/explosionfar.ogg', 100)

	// Step two of the destruction, which detonates the turfs in the earthquake zone. There is no actual explosion, meaning stuff around the earthquake zone is perfectly safe.
	// All turfs, and everything else that IS in the earthquake zone, however, will behave as if it were bombed.
	// If you are caught in the earthquake zone, you will not only die but probably be torn apart in the process.
	for(var/turf/turf_to_shred in turfs_to_shred)
		if(prob(10))
			SSexplosions.medturf += turf_to_shred
		else
			SSexplosions.highturf += turf_to_shred

		if(isasteroidturf(turf_to_shred) && prob(90))
			turf_to_shred.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
