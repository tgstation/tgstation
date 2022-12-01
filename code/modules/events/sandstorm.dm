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
	typepath = /datum/round_event/sandstorm //comments below are comparison for catastropic meteor wave numbers
	max_occurrences = 3 //3
	min_players = 35 //25
	earliest_start = 35 MINUTES //45
	category = EVENT_CATEGORY_SPACE
	description = "A wave of space dust continually grinds down a side of the station."
	///Where will the sandstorm be coming from -- Established in admin_setup, passed down to round_event
	var/start_side

/datum/round_event_control/sandstorm/admin_setup()
	if(!check_rights(R_FUN))
		return ADMIN_CANCEL_EVENT

	if(tgui_alert(usr, "Choose a side to powersand?", "I hate sand.", list("Yes", "No")) == "Yes")
		var/chosen_direction = tgui_input_list(usr, "Pick one!","Rough, gets everywhere, coarse, etc.", list("Up", "Down", "Right", "Left"))
		switch(chosen_direction)
			if("Up")
				start_side = NORTH
			if("Down")
				start_side = SOUTH
			if("Right")
				start_side = EAST
			if("Left")
				start_side = WEST

/datum/round_event/sandstorm
	start_when = 60
	end_when = 100
	announce_when = 1
	///Which direction the storm will come from.
	var/start_side

/datum/round_event/sandstorm/setup()
	start_when = rand(50, 70)
	start_when = 60
	end_when = rand(90, 110)
	end_when = 100

/datum/round_event/sandstorm/announce(fake)
	var/datum/round_event_control/sandstorm/sandstorm_event = control
	if(sandstorm_event.start_side)
		start_side = sandstorm_event.start_side
	else
		start_side = pick(GLOB.cardinals)

	var/start_side_text = "unknown"
	switch(start_side) //EOB mentioned the space maps (the only ones that can be hit by this event) using ship directions in the future. dir2text() would save lines but would acknowledge that we're using cardinals in space.
		if(NORTH)
			start_side_text = "fore"
		if(SOUTH)
			start_side_text = "aft"
		if(EAST)
			start_side_text = "starboard"
		if(WEST)
			start_side_text = "port"
	priority_announce("A large wave of space dust is approaching from the [start_side_text] side of the station. \
						All employees are encouraged to assist in repairs or mitigation of damage to external fittings and fixtures.", "Collision Emergency Alert")

/datum/round_event/sandstorm/tick()
	spawn_meteors(15, GLOB.meteorsE, start_side)


/**
 * The original sandstorm event. An admin-only disasterfest that sands down all sides of the station
 * Uses space dust, meaning walls/rwalls are quickly chewed up very quickly.
 *
 * Super dangerous, super funny, preserved for future admin use in case the new event reminds
 * them that this exists. It is unchanged from its original form.
 */

/datum/round_event_control/sandstorm_classic
	name = "Sandstorm: Classic"
	typepath = /datum/round_event/sandstorm_classic
	weight = 0
	max_occurrences = 0
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "The station is pelted by an extreme amount of dust, from all sides, for several minutes."

/datum/round_event/sandstorm_classic
	start_when = 1
	end_when = 150 // ~5 min //I don't think this actually lasts 5 minutes unless you're including the lag it induces
	announce_when = 0
	fakeable = FALSE

/datum/round_event/sandstorm_classic/tick()
	spawn_meteors(10, GLOB.meteorsC)
