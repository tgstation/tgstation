/datum/storyteller/clown
	name = "The Clown"
	desc = "The clown creates only harmless events(citation needed), its all fun and games with this one!"
	welcome_text = "You feel like the shift will be \"interesting\"."
	event_repetition_multiplier = 1 //can repeat things freely
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1.9,
		EVENT_TRACK_MODERATE = 1.8,
		EVENT_TRACK_MAJOR = 0.3,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1,
		)
	tag_multipliers = list(TAG_COMMUNAL = 1.1, TAG_SPOOKY = 1.2)
	guarantees_roundstart_roleset = FALSE
	roundstart_prob = 75
	ignores_roundstart = TRUE
