/datum/memory/revolution_rev_defeat/get_names()
	return list(
		"The defeat of [protagonist_name] at the hands of the Port Authority",
		"The end of [protagonist_name]'s glorious revolution",
	)

/datum/memory/revolution_heads_victory/get_names()
	return list("The success of [protagonist_name] and the Port Authority over the hateful revolution")

/datum/memory/revolution_heads_victory/get_starts()
	return list(
		"[protagonist_name] dusting off their hands in victory over the revoution",
		"the banner of the Port Authority flying on the bridge of [station_name()] with [protagonist_name] proudly beside it",
	)

/datum/memory/revolution_rev_defeat/get_moods()
	return list("[protagonist_name] [mood_verb] over the defeat of the revolution by the hands of the Port Authority.")
