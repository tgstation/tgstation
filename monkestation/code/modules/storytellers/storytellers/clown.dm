/datum/storyteller/clown
	name = "The CLown"
	desc = "The clown creates only(citation needed) harmless events, its all fun and games with this one!"
	welcome_text = "You feel like the shift will be \"interesting\"."
	event_repetition_multiplier = 1 //can repeat things freely
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 2,
		EVENT_TRACK_MODERATE = 1.8,
		EVENT_TRACK_MAJOR = 0.2,
		EVENT_TRACK_ROLESET = 0.8,
		EVENT_TRACK_OBJECTIVES = 1
		)
	tag_multipliers = list(TAG_COMMUNAL = 1.1, TAG_SPOOKY = 1.4) //spooky(its just a prank bro(im sorry(no im not)))
	guarantees_roundstart_roleset = FALSE
	roundstart_prob = 75
	ignores_roundstart = TRUE
