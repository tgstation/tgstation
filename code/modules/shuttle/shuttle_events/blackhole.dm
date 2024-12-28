///Sensors indicate that a black hole's gravitational field is affecting the region of space we were headed through
/datum/shuttle_event/simple_spawner/black_hole
	name = "Black Hole (Oh no!)"
	event_probability = 0 // only admin spawnable
	spawn_probability_per_process = 10
	activation_fraction = 0.35
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE
	spawning_list = list(/obj/singularity/shuttle_event = 1)
	// only spawn it once
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

///Kobayashi Maru version
/datum/shuttle_event/simple_spawner/black_hole/adminbus
	name = "Black Holes (OH GOD!)"
	spawn_probability_per_process = 50
	activation_fraction = 0.2
	spawning_list = list(/obj/singularity/shuttle_event = 10)
	remove_from_list_when_spawned = TRUE

/// No Escape traitor final objective
/datum/shuttle_event/simple_spawner/black_hole/no_escape
	name = "Black Hole Massive (is not admin spawnable)"
	spawn_probability_per_process = -1.875 // starts in the negative but increases over time
	activation_fraction = 0 // no delay
	spawning_list = list(/obj/singularity/shuttle_event/no_escape = 1)
	remove_from_list_when_spawned = TRUE
	/// How much the spawn_probability_per_process increases or decreases over time
	/// since spawn_probability starts negative after 15 seconds the prob reaches 0%
	/// then every 8 seconds after, the prob increases by ~1%
	var/probability_rate_of_change = 0.125
	/// The beacon that is drawing the singularity closer to the escape shuttle
	var/obj/machinery/power/singularity_beacon/syndicate/no_escape/beacon

/datum/shuttle_event/simple_spawner/black_hole/no_escape/proc/announcement()
	priority_announce(
		text = "Sensors indicate that a black hole's gravitational field is affecting the region of space we are heading through.",
		title = "The Orion Trail",
		sound = 'sound/announcer/notice/notice1.ogg',
		has_important_message = TRUE,
		sender_override = "Emergency Shuttle",
		color_override = "red",
	)

/datum/shuttle_event/simple_spawner/black_hole/no_escape/activate()
	. = ..()

	addtimer(CALLBACK(src, PROC_REF(announcement)), 5 SECONDS)
	port.setTimer(port.timeLeft(1) + 1 MINUTES) // the singularity causes a time distortion

/datum/shuttle_event/simple_spawner/black_hole/no_escape/event_process()
	. = ..()
	if(!.)
		return

	if((SSshuttle.emergency.mode == SHUTTLE_ESCAPE)) // only while shuttle is in transit
		if(beacon && beacon.active)
			var/area/escape_shuttle_area = get_area(beacon)
			if(istype(escape_shuttle_area, /area/shuttle/escape) && SSshuttle.emergency.is_in_shuttle_bounds(beacon))
				spawn_probability_per_process += probability_rate_of_change
			else // beacon is not on shuttle and likely got jettisoned in space
				// since the beacon is still powered and attracting the singularity it results in x2 rate of decrease
				spawn_probability_per_process -= (probability_rate_of_change * 2)
		else // beacon is unpowered or destroyed
			spawn_probability_per_process -= probability_rate_of_change

	if(prob(spawn_probability_per_process))
		spawn_movable(get_type_to_spawn())
		return SHUTTLE_EVENT_CLEAR

/datum/shuttle_event/simple_spawner/black_hole/no_escape/get_spawn_turf()
	RETURN_TYPE(/turf)

	if(beacon && beacon.active)
		var/area/escape_shuttle_area = get_area(beacon)
		if(istype(escape_shuttle_area, /area/shuttle/escape) && SSshuttle.emergency.is_in_shuttle_bounds(beacon))
			// beacon is active and on shuttle so singularity will directly hit the shuttle
			return pick(spawning_turfs_hit)

	// otherwise beacon is turned off, destroyed, or spaced so there is a chance to miss
	// the singularity is 11x11 so even a miss can have a glancing hit against the shuttle
	return pick(spawning_turfs_hit + spawning_turfs_miss)
