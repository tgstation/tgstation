/datum/storyteller/operative
	name = "The Operative"
	desc = "The Operative tries to create more direct confrontation with human threats."
	welcome_text = "The eyes of multiple organizations have been set on the station."
	starting_point_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1.1,
		EVENT_TRACK_OBJECTIVES = 1
		)
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 0.8,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1.2,
		EVENT_TRACK_OBJECTIVES = 1
		)
	tag_multipliers = list(TAG_ALIEN = 0.4, TAG_CREW_ANTAG = 1.1)
	restricted = TRUE
	population_min = 45
	ignores_roundstart = TRUE
	weight = 1
