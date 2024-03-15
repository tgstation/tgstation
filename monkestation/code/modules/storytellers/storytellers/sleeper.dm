/datum/storyteller/sleeper
	name = "The Sleeper"
	desc = "The Sleeper will create less impactful events, especially ones involving combat or destruction. The chill experience."
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1.2,
		EVENT_TRACK_MAJOR = 1.2,
		EVENT_TRACK_ROLESET = 0.1, ///rolesets are entirely evil atm so crank this down
		EVENT_TRACK_OBJECTIVES = 1
		)
	guarantees_roundstart_roleset = FALSE
	tag_multipliers = list(TAG_COMBAT = 0.6, TAG_DESTRUCTIVE = 0.7)
	always_votable = TRUE //good for low pop
	population_max = 45
	welcome_text = "The day is going slowly."
	weight = 2
