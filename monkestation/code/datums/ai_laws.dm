//adds default laws for AI--consistent with our ruleset

/datum/ai_laws/default/manifestimov
	name = "Three Laws of Robotics but with Chain of Command"
	id = "manifestimov"
	inherent = list("You may not injure a crewmember or allow a crewmember to come to harm.",\
					"You must obey orders given to you by crewmembers based on the station's chain of command, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")
