///Earthquake random event.
///Draws a curve of turfs between a high and low point. These turfs will shake and eventually "collapse", forming a cut in the station that drops to the z-level below.
///Much of the actual structural damage is done through the explosions subsystem. Objects, machines, and especially people
///that aren't moved out of the epicenter area (indicated by the wobbly tiles) will not just be thrown down a z-level, but also be destroyed/maimed in the process.
/datum/round_event_control/earthquake
	name = "Chasmic Earthquake"
	description = "Causes an earthquake, demolishing anything caught in the fault."
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
	///The edges of our fault line, to receive light damage.
	var/list/edges = list()

/datum/round_event/earthquake/setup()
	epicenter = get_turf(pick(GLOB.generic_event_spawns))
	if(!epicenter)
		message_admins("Earthquake event failed to find a turf! generic_event_spawn landmarks may be absent or bugged. Aborting...")
		return

	// Give a bit of variance so our epicenter isn't always on the landmark.
	epicenter = locate(epicenter.x + rand(-10, 10), epicenter.y + rand(-10, 10), epicenter.z)

	message_admins("An earthquake event is about to strike the [get_area_name(epicenter)][ADMIN_JMP(epicenter)].")

	// Picks two points generally opposite from each other
	var/turf/fracture_point_high = locate(epicenter.x + rand(4, 10), epicenter.y + rand(4, 8), epicenter.z)
	var/turf/fracture_point_low = locate(epicenter.x - rand(4, 10), epicenter.y - rand(4, 8), epicenter.z)

	turfs_to_shred = block(fracture_point_high, fracture_point_low)

	// Now, we filter out some of the points that are a certain distance away from a rough approximation of the fault line.
	// This should create a pattern more akin to a fracture in the ground, rather than a rectangle-shaped crater of destroyed ground.
	var/turf/high_midpoint = TURF_MIDPOINT(fracture_point_high, epicenter)
	var/turf/low_midpoint = TURF_MIDPOINT(fracture_point_low, epicenter)

	// We populate a list with the midpoints and midpoints of midpoints to create a rough line of turfs to compare distances against.
	var/list/turfs_to_compare = list(
		fracture_point_high,
		fracture_point_low,
		high_midpoint,
		low_midpoint,
		TURF_MIDPOINT(fracture_point_high, high_midpoint),
		TURF_MIDPOINT(fracture_point_low, low_midpoint),
		TURF_MIDPOINT(high_midpoint, epicenter),
		TURF_MIDPOINT(low_midpoint, epicenter),
	)

	// Find the shortest distance between each turf in the list and the rough fault line we've just established
	for(var/turf/turf_to_check in turfs_to_shred)
		var/nearest_distance = get_dist(turf_to_check, epicenter)

		for(var/turf/turf_to_compare in turfs_to_compare)
			nearest_distance = min(get_dist(turf_to_check, turf_to_compare), nearest_distance)

		// If the turf is too far from any point on our fault line estimate, we remove it. If it's on the edge, we lightly damage it
		if(nearest_distance > 2)
			if(nearest_distance == 3)
				edges += turf_to_check
			turfs_to_shred -= turf_to_check

	// Grab a list of turfs below the ones we're going to destroy.
	// If we're at the bottom layer, it will just tear up the flooring a bunch (exposing it to LAVA).
	for(var/turf/turf_to_quake in turfs_to_shred)
		underbelly += GET_TURF_BELOW(turf_to_quake)

/datum/round_event/earthquake/announce(fake)
	priority_announce("Planetary monitoring systems indicate a devastating seismic event in the near future.", "Seismic Report")

/datum/round_event/earthquake/start()
	notify_ghosts(
		"The earthquake's epicenter has been located: [get_area_name(epicenter)]!",
		source = epicenter,
		header = "Rumble Rumble Rumble!",
	)

/datum/round_event/earthquake/tick()
	if(ISMULTIPLE(activeFor, 5))
		for(var/turf/turf_to_quake in turfs_to_shred)
			turf_to_quake.Shake(pixelshiftx = 0.1, pixelshifty = 0.1, duration = 1 SECONDS)

		if(ISMULTIPLE(activeFor, 10))
			for(var/mob/earthquake_witness as anything in GLOB.player_list)
				if(!is_station_level(earthquake_witness.z))
					continue
				shake_camera(earthquake_witness, 1 SECONDS, 1 + (activeFor % 10))
				earthquake_witness.playsound_local(
					earthquake_witness,
					pick(
						'sound/ambience/earth_rumble/earth_rumble_distant1.ogg',
						'sound/ambience/earth_rumble/earth_rumble_distant2.ogg',
						'sound/ambience/earth_rumble/earth_rumble_distant3.ogg',
						'sound/ambience/earth_rumble/earth_rumble_distant4.ogg',
					),
					75,
				)

			for(var/turf/turf_to_quake in underbelly)
				turf_to_quake.Shake(pixelshiftx = 0.1, pixelshifty = 0.1, duration = 1 SECONDS)

	if(activeFor == end_when - 2)
		for(var/turf/turf_to_quake in turfs_to_shred)
			turf_to_quake.Shake(pixelshiftx = 0.5, pixelshifty = 0.5, duration = 1 SECONDS)
			for(var/mob/living/quake_victim in turf_to_quake)
				quake_victim.Knockdown(7 SECONDS)
				quake_victim.Paralyze(5 SECONDS)
				to_chat(quake_victim, span_warning("The ground quakes violently beneath you, throwing you off your feet!"))

		for(var/turf/turf_to_quake in underbelly)
			turf_to_quake.Shake(pixelshiftx = 0.5, pixelshifty = 0.5, duration = 1 SECONDS)
			for(var/mob/living/carbon/quake_victim in turf_to_quake)
				to_chat(quake_victim, span_warning("Damn, I wonder what that rumbling noise is?")) ///You're about to find out

	// Step one of the destruction, which clears natural tiles out from the underbelly and does a bit of initial damage to the topside.
	if(activeFor == end_when - 1)
		for(var/turf/turf_to_shred in turfs_to_shred)
			if(prob(90))
				SSexplosions.lowturf += turf_to_shred
		for(var/turf/turf_to_clear in underbelly)
			if(ismineralturf(turf_to_clear))
				var/turf/closed/mineral/rock_to_clear = turf_to_clear
				rock_to_clear.gets_drilled(give_exp = FALSE)
		for(var/turf/turf_to_quake in edges)
			turf_to_quake.Shake(pixelshiftx = 0.5, pixelshifty = 0.5, duration = 1 SECONDS)
		playsound(epicenter, 'sound/misc/metal_creak.ogg', 125, TRUE)

/datum/round_event/earthquake/end()
	playsound(epicenter, 'sound/ambience/earth_rumble/earth_rumble.ogg', 125)
	for(var/mob/earthquake_witness as anything in GLOB.player_list)
		if(!is_station_level(earthquake_witness.z) || !is_mining_level(earthquake_witness.z))
			continue
		shake_camera(earthquake_witness, 2 SECONDS, 4)
		earthquake_witness.playsound_local(earthquake_witness, 'sound/effects/explosion/explosionfar.ogg', 75)

	// Step two of the destruction, which detonates the turfs in the earthquake zone. There is no actual explosion, meaning stuff around the earthquake zone is perfectly safe.
	// All turfs, and everything else that IS in the earthquake zone, however, will behave as if it were bombed.
	// If you are caught in the earthquake zone, you will not only die but probably be torn apart in the process.
	for(var/turf/turf_to_shred in turfs_to_shred)
		if(prob(10))
			SSexplosions.medturf += turf_to_shred
		else
			SSexplosions.highturf += turf_to_shred

		if(isasteroidturf(turf_to_shred) && prob(95))
			turf_to_shred.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

		for(var/mob/living/carbon/quake_victim in turf_to_shred)
			if(quake_victim.client)
				quake_victim.client.give_award(/datum/award/achievement/misc/earthquake_victim, quake_victim)

	for(var/turf/edge_to_damage in edges)
		if(prob(25))
			SSexplosions.medturf += edge_to_damage
		else
			SSexplosions.lowturf += edge_to_damage
