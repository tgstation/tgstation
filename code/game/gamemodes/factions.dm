
// Normal factions:

/datum/faction
	var/name		// the name of the faction
	var/desc		// small paragraph explaining the traitor faction

	var/list/restricted_species = list() // only members of these species can be recruited.
	var/list/members = list() 	// a list of mind datums that belong to this faction
	var/max_op = 0		// the maximum number of members a faction can have (0 for no max)

// Factions, members of the syndicate coalition:

/datum/faction/syndicate

	var/list/alliances = list() // these alliances work together
	var/list/equipment = list() // associative list of equipment available for this faction and its prices
	var/friendly_identification	// 0 to 2, the level of identification of fellow operatives or allied factions
								// 0 - no identification clues
								// 1 - faction gives key words and phrases
								// 2 - faction reveals complete identity/job of other agents
	var/operative_notes // some notes to pass onto each operative

	var/uplink_contents			// the contents of the uplink

	proc/assign_objectives(var/datum/mind/traitor)
		..()


/* ----- Begin defining syndicate factions ------ */

/datum/faction/syndicate/Cybersun_Industries
	name = "Cybersun Industries"
	desc = "<b>Cybersun Industries</b> is a well-known organization that bases its business model primarily on the research and development of human-enhancing computer \
			and mechanical technology. They are notorious for their aggressive corporate tactics, and have been known to subsidize the Gorlex Marauder warlords as a form of paid terrorism. \
			Their competent coverups and unchallenged mind-manipulation and augmentation technology makes them a large threat to Nanotrasen. In the recent years of \
			the syndicate coalition, Cybersun Industries have established themselves as the leaders of the coalition, succeededing the founding group, the Gorlex Marauders."

	alliances = list("MI13")
	friendly_identification = 1
	max_op = 3

	// Friendly to everyone. (with Tiger Cooperative too, only because they are a member of the coalition. This is the only reason why the Tiger Cooperative are even allowed in the coalition)

/datum/faction/syndicate/Donk
	name = "Donk Corporation"
	desc = "<b>Donk.co</b> is led by a group of ex-pirates, who used to be at a state of all-out war against Waffle.co because of an obscure political scandal, but have recently come to a war limitation. \
			They now consist of a series of colonial governments and companies. They were the first to officially begin confrontations against Nanotrasen because of an incident where \
			Nanotrasen purposely swindled them out of a fortune, sending their controlled colonies into a terrible poverty. Their missions against Nanotrasen \
			revolve around stealing valuables and kidnapping and executing key personnel, ransoming their lives for money. They merged with a splinter-cell of Waffle.co who wanted to end \
			hostilities and formed the Gorlex Marauders."

	alliances = list("Gorlex Marauders")
	friendly_identification = 2
	operative_notes = "Most other syndicate operatives are not to be trusted, except fellow Donk members and members of the Gorlex Marauders. We do not approve of mindless killing of innocent workers; \"get in, get done, get out\" is our motto. Members of Waffle.co are to be killed on sight; they are not allowed to be on the station while we're around."

	// Neutral to everyone, friendly to Marauders

/datum/faction/syndicate/Waffle
	name = "Waffle Corporation"
	desc = "<b>Waffle.co</b> is an interstellar company that produces the best waffles in the galaxy. Their waffles have been rumored to be dipped in the most exotic and addictive \
			drug known to man. They were involved in a political scandal with Donk.co, and have since been in constant war with them. Because of their constant exploits of the galactic \
			economy and stock market, they have been able to bribe their way into amassing a large arsenal of weapons of mass destruction. They target Nanotrasen because of their communistic \
			threat, and their economic threat. Their leaders often have a twisted sense of humor, often misleading and intentionally putting their operatives into harm for laughs.\
			A splinter-cell of Waffle.co merged with Donk.co and formed the Gorlex Marauders and have been a constant ally since. The Waffle.co has lost an overwhelming majority of its military to the Gorlex Marauders."

	alliances = list("Gorlex Marauders")
	friendly_identification = 2
	operative_notes = "Most other syndicate operatives are not to be trusted, except for members of the Gorlex Marauders. Do not trust fellow members of the Waffle.co (but try not to rat them out), as they might have been assigned opposing objectives. We encourage humorous terrorism against Nanotrasen; we like to see our operatives creatively kill people while getting the job done."

	// Neutral to everyone, friendly to Marauders


/* ----- Begin defining miscellaneous factions ------ */

/datum/faction/Wizard
	name = "Wizards Federation"
	desc = "The <b>Wizards Federation</b> is a mysterious organization of magically-talented individuals who act as an equal collective, and have no heirarchy. It is unknown how the wizards \
			are even able to communicate; some suggest a form of telepathic hive-mind. Not much is known about the wizards or their philosphies and motives. They appear to attack random \
			civilian, corporate, planetary, orbital, pretty much any sort of organized facility they come across. Members of the Wizards Federation are considered amongst the most dangerous \
			individuals in the known universe, and have been labeled threats to humanity by most governments. As such, they are enemies of both Nanotrasen and the Syndicate."

/datum/faction/Cult
	name = "The Cult of the Elder Gods"
	desc = "<b>The Cult of the Elder Gods</b> is highly untrusted but otherwise elusive religious organization bent on the revival of the so-called \"Elder Gods\" into the mortal realm. Despite their obvious dangeorus practices, \
			no confirmed reports of violence by members of the Cult have been reported, only rumor and unproven claims. Their nature is unknown, but recent discoveries have hinted to the possibility \
			of being able to de-convert members of this cult through what has been dubbed \"religious warfare\"."


// These can maybe be added into a game mode or a mob?

/datum/faction/Exolitics
	name = "Exolitics United"
	desc = "The <b>Exolitics</b> are an ancient alien race with an energy-based anatomy. Their culture, communication, morales and knowledge is unknown. They are so radically different to humans that their \
			attempts of communication with other life forms is completely incomprehensible. Members of this alien race are capable of broadcasting subspace transmissions from their bodies. \
			The religious leaders of the Tiger Cooperative claim to have the technology to decypher and interpret their messages, which have been confirmed as religious propaganda. Their motives are unknown \
			but they are otherwise not considered much of a threat to anyone. They are virtually indestructable because of their nonphysical composition, and have the frighetning ability to make anything stop existing in a second."