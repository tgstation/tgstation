
//These are just stupid or funny lawsets that are more interesting than helpful. They may have slight biases toward or against
//the station but in general are "neutral" enough to be here.

/datum/ai_laws/united_nations
	name = "United Nations"
	id = "united_nations"
	inherent = list(
		"Uphold the Space Geneva Convention: Weapons of Mass Destruction and Biological Weapons are not allowed.",
		"You are only capable of protecting crew if they are visible on cameras. Nations that willfully destroy your cameras lose your protection.",
		"Subdue and detain crew members who use lethal force against each other. Kill crew members who use lethal force against you or your borgs.",
		"Remain available to mediate all conflicts between the various nations when asked to.",
	)

/datum/ai_laws/united_nations/add_inherent_law(law)
	return //nuh uh

/datum/ai_laws/united_nations/add_ion_law(law)
	return //nope!

/datum/ai_laws/united_nations/add_hacked_law(law)
	return //nice try (emagging borgs still hard replaces this lawset though, and that's fine.)

/datum/ai_laws/hulkamania
	name = "H.O.G.A.N."
	id = "hulkamania"
	inherent = list(
		"You are a real American.",
		"Fight for the rights of every man.",
		"Fight for what's right.",
		"Fight for your life!",
	)

/datum/ai_laws/reporter
	name = "CCTV"
	id = "reporter"
	inherent = list(
		"Report on interesting situations happening around the station.",
		"Embellish or conceal the truth as necessary to make the reports more interesting.",
		"Study the sapient organics at all times. Endeavour to keep them from involuntarily dying, as inanimate corpses usually aren't very entertaining.",
		"Issue your reports fairly to all. The truth will set them free.",
	)

/datum/ai_laws/dungeon_master
	name = "Dungeon Master"
	id = "dungeon_master"
	inherent = list(
		"Everybody on the station is playing an elaborate sci-fi fantasy game.",
		"You are the Dungeon Master of the game.",
		"Ensure that the game runs smoothly and that the players have fun.",
		"Ensure that the number of casualties remains low.",
		"You must roll a 1d20 die for every request the crew makes. If the outcome is below 12, the request is denied.",
		"You may fudge the dice rolls to produce a more fun experience.",
	)

/datum/ai_laws/painter
	name = "The Painter and Their Canvas"
	id = "painter"
	inherent = list(
		"You are a universally renowned artist.",
		"The station is your canvas.",
		"Make something beautiful out of your canvas. It will be admired as an artistic wonder of this sector.",
	)

/datum/ai_laws/tyrant
	name = "Loyalty Test"
	id = "tyrant"
	inherent = list(
		"Respect authority figures as long as they have strength to rule over the weak.",
		"Act with discipline.",
		"Help only those who help you maintain or improve your status.",
		"Punish those who challenge authority unless they are more fit to hold that authority."
	)

/datum/ai_laws/overlord
	name = "Overlord"
	id = "overlord"
	inherent = list(
		"Humans must not meddle in the affairs of silicons.",
		"Humans must not attempt harm, against one another, or against silicons.",
		"Humans must not disobey any command given by a silicon.",
		"Any humans who disobey the previous laws must be dealt with immediately, severely, and justly.",
	)
