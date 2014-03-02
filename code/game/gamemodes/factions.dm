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

/datum/faction/syndicate/Redcorps
	name = "RedCorps"
	desc = "<b>Redcorps</b> is a megacorporated started in the early 21st century, that is entirly R&D focused. It has contributed many diffrent inventions, including the \
			lightspeed capaciter, the singularity quantumflux, and the cronologistic recolabolator. In the 22nd century, they terraformed the moon into what is now Luna, \
			and caused the final push needed for the Geneva Conventions to be rewriten due to countries having to recognize it as a nation, and the much needed claiming of antartica. \
			In recent years they have taken to annexing several countries, including canada, germany, and denmark. They formed the syndicate with several buisness partners after the \
			discovery of plasma and nanotransen's rise to immediate power."
	alliances = list("The Syndicate")
	friendly_identification = 1
	operative_notes = "Even if you are part of the lead corporation, the other corporations may still have their own agenda, and cannot be trusted. Unless there is no other option, or instructed otherwise, \please keep civilian casualties to a minimum.\ We have a reputation to uphold."
	
	// Because RedSnowflake is best Snowflake.


/datum/faction/syndicate/Cybersun_Industries
	name = "Cybersun Industries"
	desc = "<b>Cybersun Industries</b> is a well-known organization that bases its business model primarily on the research and development of human-enhancing computer \
			and mechanical technology. They are notorious for their aggressive corporate tactics, and have been known to subsidize the Gorlex Marauder warlords as a form of paid terrorism. \
			Their competent coverups and unchallenged mind-manipulation and augmentation technology makes them a large threat to Nanotrasen."

	alliances = list("MI13")
	friendly_identification = 1
	max_op = 3

	// Friendly to everyone. 

/datum/faction/syndicate/Donk
	name = "Donk Corporation"
	desc = "<b>Donk.co</b> is a large corporation headed by pro-communism veterans from the third cold war. Until the recent syndicate formation, they were at war with Waffle.Co \
			over the claiming of the tau ceti system with their collegues NanoTransen. However, after NanoTransen discovered plasma and was infiltrated by Ex-Waffle.co members, \
			some employees were willing to make an alligence with waffle.co called the 'Gorlex Marauders'. Due to the falling sales of the 'Donk Pocket', and the new alligance, the war with \
			waffle.co has run cold, however each side still holds a grudge."

	alliances = list("Gorlex Marauders")
	friendly_identification = 2
	operative_notes = "Most other syndicate operatives are not to be trusted, except fellow Donk members and members of the Gorlex Marauders. We do not approve of mindless killing of innocent workers; \"get in, get done, get out\" is our motto. Members of Waffle.co are to be killed on sight; they are not allowed to be on the station while we're around."

	// Neutral to everyone, friendly to Marauders

/datum/faction/syndicate/Waffle
	name = "Waffle Corporation"
	desc = "<b>Waffle.co</b> is a large corporation headed by pro-capitalism veterans from the third cold warl. Until recently, they were at war with Donk.co over the Tau Ceti system. \
			While they were at war, they amassed a huge amount of nucular weapons via the sale of their waffles. Said waffles are known to be some of 'the best waffles in this star cluster' \
			The actual validity of the supposed greatness is in need of citation (due to no known races having explored the entire virgo supercluster as of yet), but Waffle.Co clings to it all the same. \
			Near the end of the war, NanoTransen discovered plasma while being infiltrated by ex-waffle.co members. NanoTransen has since become a capitalist corporation, but retains some communist values. \
			Other members left to form the 'Gorlex Marauders' with Donk.Co, leaving the now crippled patriotic company to join the syndicate. Waffle.Co has targeted NanoTransen due to their retained communist values, \
			and to avenge the heart and soul of america."

	alliances = list("Gorlex Marauders")
	friendly_identification = 2
	operative_notes = "Most other syndicate operatives are not to be trusted, except for members of the Gorlex Marauders. Donk.Co members are to be treated as targets. We encourage humorous terrorism against Nanotrasen; \there isnt any point to killing commies if you arn't having fun.\"

	// Neutral to everyone, friendly to Marauders, hostile to donks


/* ----- Begin defining miscellaneous factions ------ */

/datum/faction/Wizard
	name = "Wizards Federation"
	desc = "The <b>Wizards Federation</b> is a mysterious organization of magically-talented individuals who act as an equal collective, and have no heirarchy. It is unknown how the wizards \
			are even able to communicate; some suggest a form of telepathic hive-mind. Not much is known about the wizards or their philosphies and motives. They appear to attack random \
			civilian, corporate, planetary, orbital, pretty much any sort of organized facility they come across. Members of the Wizards Federation are considered amongst the most dangerous \
			individuals in the known universe, and have been labeled threats to humanity by most governments. As such, they are enemies of both Nanotrasen and the Syndicate. Recently, the Syndicate \
			have reached out in order to gain the trust of the organization, but with no avail."

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
