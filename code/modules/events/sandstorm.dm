/**
 * Sandstorm Event: Throws dust/sand at one side of the station. High-intensity and relatively short,
 * however the incoming direction is given along with time to prepare. Damages can be reduced or
 * mitigated with a few people actively working to fix things as the storm hits, but leaving the event to run on its own can lead to widespread breaches.
 *
 * Meant to be encountered mid-round, with enough spare manpower among the crew to properly respond.
 * Anyone with a welder or metal can contribute.
 */

/datum/round_event_control/sandstorm
	name = "Sandstorm: Directional"
	typepath = /datum/round_event/sandstorm
	max_occurrences = 3
	min_players = 35
	earliest_start = 35 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "A wave of space dust continually grinds down a side of the station."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7
	admin_setup = /datum/event_admin_setup/listed_options/sandstorm
	map_flags = EVENT_SPACE_ONLY

/datum/round_event/sandstorm
	start_when = 60
	end_when = 100
	announce_when = 1
	///Which direction the storm will come from.
	var/start_side

/datum/round_event/sandstorm/setup()
	start_when = rand(70, 90)
	end_when = rand(110, 140)

/datum/round_event/sandstorm/announce(fake)
	if(!start_side)
		start_side = pick(GLOB.cardinals)

	var/start_side_text = "unknown"
	switch(start_side)
		if(NORTH)
			start_side_text = "fore"
		if(SOUTH)
			start_side_text = "aft"
		if(EAST)
			start_side_text = "starboard"
		if(WEST)
			start_side_text = "port"
		else
			stack_trace("Sandstorm event given [start_side] as unrecognized direction. Cancelling event...")
			kill()
			return

	priority_announce("A large wave of space dust is approaching from the [start_side_text] side of the station. \
		Impact is expected in the next two minutes. All employees are encouranged to assist in repairs and damage mitigation if possible.", "Collision Emergency Alert")

/datum/round_event/sandstorm/tick()
	spawn_meteors(15, GLOB.meteors_sandstorm, start_side)

/**
 * The original sandstorm event. An admin-only disasterfest that sands down all sides of the station
 * Uses space dust, meaning walls/rwalls are quickly chewed up very quickly.
 *
 * Super dangerous, super funny, preserved for future admin use in case the new event reminds
 * them that this exists. It is unchanged from its original form and is arguably perfect.
 */

/datum/round_event_control/sandstorm_classic
	name = "Sandstorm: Classic"
	typepath = /datum/round_event/sandstorm_classic
	weight = 0
	max_occurrences = 0
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "The station is pelted by an extreme amount of dust, from all sides, for several minutes. Very destructive and likely to cause lag. Use at own risk."
	map_flags = EVENT_SPACE_ONLY

/datum/round_event/sandstorm_classic
	start_when = 1
	end_when = 150 // ~5 min //I don't think this actually lasts 5 minutes unless you're including the lag it induces
	announce_when = 0
	fakeable = FALSE

/datum/round_event/sandstorm_classic/tick()
	spawn_meteors(10, GLOB.meteors_dust)

/datum/event_admin_setup/listed_options/sandstorm
	input_text = "Choose a side to powersand?"
	normal_run_option = "Random Sandstorm Direction"

/datum/event_admin_setup/listed_options/sandstorm/get_list()
	return list("Up", "Down", "Right", "Left")

/datum/event_admin_setup/listed_options/sandstorm/apply_to_event(datum/round_event/sandstorm/event)
	switch(chosen)
		if("Up")
			event.start_side = NORTH
		if("Down")
			event.start_side = SOUTH
		if("Right")
			event.start_side = EAST
		if("Left")
			event.start_side = WEST
