/datum/round_event_control/space_dust
	name = "Space Dust: Minor"
	typepath = /datum/round_event/space_dust
	weight = 200
	max_occurrences = 1000
	earliest_start = 0 MINUTES
	alert_observers = FALSE
	category = EVENT_CATEGORY_SPACE
	description = "A single space dust is hurled at the station."

/datum/round_event/space_dust
	start_when = 1
	end_when = 2
	fakeable = FALSE

/datum/round_event/space_dust/start()
	spawn_meteors(1, GLOB.meteorsC)

/datum/round_event_control/space_dust/major_dust
	name = "Space Dust: Major"
	typepath = /datum/round_event/space_dust/major_dust
	weight = 8
	description = "The station is pelted by sand."
	min_players = 15
	max_occurrences = 3
	earliest_start = 25 MINUTES
	category = EVENT_CATEGORY_SPACE

/datum/round_event/space_dust/major_dust
	start_when = 6
	end_when = 66
	announce_when = 1

/datum/round_event/space_dust/major_dust/announce(fake)
	var/reason = pick(
		"The station is passing through a debris cloud, expect minor damage \
		to external fittings and fixtures.",
		"Nanotrasen Superweapons Division is testing a new prototype \
		[pick("field","projection","nova","super-colliding","reactive")] \
		[pick("cannon","artillery","tank","cruiser","\[REDACTED\]")], \
		some mild debris is expected.",
		"A neighbouring station is throwing rocks at you. (Perhaps they've \
		grown tired of your messages.)")
	priority_announce(pick(reason), "Collision Alert")

/datum/round_event/space_dust/major_dust/tick()
	if(ISMULTIPLE(activeFor, 3))
		spawn_meteors(5, GLOB.meteorsC)

/datum/round_event_control/sandstorm
	name = "Space Dust: Sandstorm"
	typepath = /datum/round_event/sandstorm
	weight = 8
	max_occurrences = 2
	earliest_start = 30 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "A wave of space dust continually grinds down a side of the station."
	///Where will the sandstorm be coming from -- Established in admin_setup, passed down to round_event
	var/start_side

/datum/round_event_control/sandstorm/admin_setup()
	if(!check_rights(R_FUN))
		return

	if(tgui_alert(usr, "Choose a side to powersand?", "I hate sand.", list("Yes", "No")) == "Yes")
		start_side = tgui_input_list(usr, "Pick one!","Rough, gets everywhere, coarse, etc.", GLOB.cardinals)

/datum/round_event/sandstorm
	start_when = 60
	end_when = 140 // much shorter now (a little over a minute), but spread out over less time to make it less drawn out
	announce_when = 1
	///Which direction the storm will come from.
	var/start_side
	///Start side var, translated into a nautical direction for presentation in setup().
	var/start_side_text = "unknown"

/datum/round_event/sandstorm/announce(fake)
	var/datum/round_event_control/sandstorm/sandstorm_event = control
	if(sandstorm_event.start_side)
		start_side = sandstorm_event.start_side
	else
		start_side = pick(GLOB.cardinals)
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
						Engineering intervention and use of shield generators may be required to prevent serious \
						damage to external fittings and fixtures.", "Collision Alert")

/datum/round_event/sandstorm/tick()
	spawn_meteors(10, GLOB.meteorsC, start_side)
