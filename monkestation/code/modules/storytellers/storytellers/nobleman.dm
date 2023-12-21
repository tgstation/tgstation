/datum/storyteller/nobleman
	name = "The Nobleman"
	desc = "The Nobleman enjoys a good fight but abhors senseless destruction. Prefers heavy hits on single targets."
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1.2,
		EVENT_TRACK_MAJOR = 1.15,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1
		)
	tag_multipliers = list(TAG_COMBAT = 1.4, TAG_DESTRUCTIVE = 0.4)
