/datum/storyteller/clown
	name = "The Clown"
	desc = "The clown creates only harmless events(citation needed), its all fun and games with this one!"
	welcome_text = "HONKHONKHONKHONKHONK!"
	event_repetition_multiplier = 1 //can repeat things freely
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 5, //admin only, welcome to hell
		EVENT_TRACK_MODERATE = 4,
		EVENT_TRACK_MAJOR = 0.3,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1,
		)
	tag_multipliers = list(TAG_COMMUNAL = 1.1, TAG_SPOOKY = 1.2)
	guarantees_roundstart_roleset = FALSE
	restricted = TRUE //admins can still use this if they want the crew to really suffer, for that reason im going all in
	roundstart_prob = 75
	ignores_roundstart = TRUE
