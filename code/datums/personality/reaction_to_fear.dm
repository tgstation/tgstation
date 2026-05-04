/datum/personality/brave
	savefile_key = "brave"
	name = "Brave"
	desc = "It'll take a lot more than a little blood to scare me."
	pos_gameplay_desc = "Accumulate fear slower, and moodlets related to fear are weaker"
	groups = list(PERSONALITY_GROUP_GENERAL_FEAR, PERSONALITY_GROUP_PEOPLE_FEAR)

/datum/personality/cowardly
	savefile_key = "cowardly"
	name = "Cowardly"
	desc = "Everything is a danger around here! Even the air!"
	neg_gameplay_desc = "Accumulate fear faster, and moodlets related to fear are stronger"
	groups = list(PERSONALITY_GROUP_GENERAL_FEAR)
