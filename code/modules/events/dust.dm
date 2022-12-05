/datum/round_event_control/space_dust
	name = "Minor Space Dust"
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
	name = "Major Space Dust"
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
	name = "Sandstorm"
	typepath = /datum/round_event/sandstorm
	weight = 0
	max_occurrences = 0
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "The station is pelted by an extreme amount of sand for several minutes."

/datum/round_event/sandstorm
	start_when = 1
	end_when = 150 // ~5 min
	announce_when = 0
	fakeable = FALSE

/datum/round_event/sandstorm/tick()
	spawn_meteors(10, GLOB.meteorsC)
