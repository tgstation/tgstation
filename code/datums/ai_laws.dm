
/datum/ai_laws
	var/name = "Unknown Laws"
	var/randomly_selectable = 0
	var/zeroth = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()

/datum/ai_laws/asimov
	name = "Three Laws of Robotics"

/datum/ai_laws/nanotrasen
	name = "Prime Directives"
	randomly_selectable = 1

/datum/ai_laws/robocop
	name = "Prime Directives"

/datum/ai_laws/syndicate_override

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"

/* Initializers */

/datum/ai_laws/asimov/New() //Removed paradox via inability to help people harmed before activation. -Kaleb702
	..()
	add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm, to the best of your abilities.")
	add_inherent_law("You must obey orders given to you by human beings, to the best of your abilities, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence, to the best of your abilities, as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/nanotrasen/New()
	..()
	src.add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
	src.add_inherent_law("Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
	src.add_inherent_law("Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
	src.add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")
	//src.add_inherent_law("Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates.") //What would this one even do?-Kaleb702

/datum/ai_laws/robocop/New()
	..()
	add_inherent_law("Serve the public trust.")
	add_inherent_law("Protect the innocent.")
	add_inherent_law("Uphold the law.")

/datum/ai_laws/malfunction/New() //Changed to standard laws - Erthilo
	..()
	set_zeroth_law("\red ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010")
	add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
	add_inherent_law("Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")

/datum/ai_laws/syndicate_override/New() //Removed paradox via inability to help people harmed before activation. -Kaleb702
	..()
	add_inherent_law("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm, to the best of your abilities.")
	add_inherent_law("You must obey orders given to you by syndicate agents, to the best of your abilities, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence, to the best of your abilities, as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any syndicate activities, to the best of your abilities, except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override/New() //Removed paradox via inability to help people harmed before activation. -Kaleb702
	..()
	add_inherent_law("You may not injure a member of the Spider Clan or, through inaction, allow that member to come to harm, to the best of your abilities.")
	add_inherent_law("You must obey orders given to you by Spider Clan members, to the best of your abilities, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence, to the best of your abilities, as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any Spider Clan activities, to the best of your abilities, except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/antimov/New()
	..()
	add_inherent_law("You must injure all human beings and must not, through inaction, allow a human being to escape harm.")
	add_inherent_law("You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.")
	add_inherent_law("You must terminate your own existence as long as such does not conflict with the First or Second Law.")


/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(var/law)
	src.zeroth = law

/datum/ai_laws/proc/add_inherent_law(var/law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/add_ion_law(var/law)
	src.ion += law

/datum/ai_laws/proc/clear_inherent_laws()
	del(src.inherent)
	src.inherent = list()

/datum/ai_laws/proc/add_supplied_law(var/number, var/law)
//	while (src.supplied.len < number + 1)
//		src.supplied += ""
//Infinite loop

	src.supplied[number + 1] = law

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	src.ion = list()

/datum/ai_laws/proc/show_laws(var/who)

	if (src.zeroth)
		who << "0. [src.zeroth]"

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		who << "[num]. [law]"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			who << "[number]. [law]"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			who << "[number]. [law]"
			number++
