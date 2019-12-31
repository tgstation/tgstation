/datum/language/drone
	name = "Drone"
	desc = "A heavily encoded damage control coordination stream, with special flags for hats."
	speech_verb = "chitters"
	ask_verb = "chitters inquisitively"
	exclaim_verb = "chitters loudly"
	spans = list(SPAN_ROBOT)
	key = "d"
	flags = NO_STUTTER
	syllables = list(".", "|")
	// ...|..||.||||.|.||.|.|.|||.|||
	space_chance = ZERO
	sentence_chance = ZERO
	default_priority = 20

	icon_state = "drone"
