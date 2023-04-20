/datum/round_event_control/space_dust
	name = "Space Dust: Minor"
	typepath = /datum/round_event/space_dust
	weight = 200
	max_occurrences = 1000
	earliest_start = 0 MINUTES
	alert_observers = FALSE
	category = EVENT_CATEGORY_SPACE
	description = "A single space dust is hurled at the station."
	map_flags = EVENT_SPACE_ONLY

/datum/round_event/space_dust
	start_when = 1
	end_when = 2
	fakeable = FALSE

/datum/round_event/space_dust/start()
	spawn_meteors(1, GLOB.meteors_dust)

/datum/round_event_control/space_dust/major_dust
	name = "Space Dust: Major"
	typepath = /datum/round_event/space_dust/major_dust
	weight = 14
	description = "The station is pelted by sand."
	min_players = 15
	max_occurrences = 3
	earliest_start = 10 MINUTES
	alert_observers = TRUE
	category = EVENT_CATEGORY_SPACE
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7

/datum/round_event/space_dust/major_dust
	start_when = 6
	end_when = 66
	announce_when = 1
	announce_chance = 55

/datum/round_event/space_dust/major_dust/announce(fake)
	var/list/reasons = list()

	reasons +=	"[station_name()] is passing through a debris cloud, expect minor damage \
		to external fittings and fixtures."

	reasons += "Nanotrasen Superweapons Division is testing a new prototype \
		[pick("field","projection","nova","super-colliding","reactive")] \
		[pick("cannon","artillery","tank","cruiser","\[REDACTED\]")], \
		some mild debris is expected."

	reasons += "A neighbouring station is throwing rocks at you. (Perhaps they've \
		grown tired of your messages.)"

	reasons += "[station_name()]'s orbit is passing through a cloud of remnants from an asteroid \
		mining operation. Minor hull damage is to be expected."

	reasons += "A large meteoroid on intercept course with [station_name()] has been demolished. \
		Residual debris may impact the station exterior."

	reasons += "[station_name()] has hit a particularly rough patch of space. \
		Please mind any turbulence or damage from debris."

	priority_announce(pick(reasons), "Collision Alert")

/datum/round_event/space_dust/major_dust/tick()
	if(ISMULTIPLE(activeFor, 3))
		spawn_meteors(5, GLOB.meteors_dust)
