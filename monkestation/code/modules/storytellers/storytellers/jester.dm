/datum/storyteller/jester
	name = "The Jester"
	desc = "The Jester will create much more events, with higher possibilities of them repeating."
	event_repetition_multiplier = 0.8
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1.2,
		EVENT_TRACK_MODERATE = 1.3,
		EVENT_TRACK_MAJOR = 1.3,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1
		)
	population_min = 40
	ignores_roundstart = TRUE
	weight = 2
