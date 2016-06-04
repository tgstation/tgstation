/datum/ai_laws
	var/name = "Unknown Laws"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()
	var/mob/living/silicon/owner

/datum/ai_laws/default/asimov
	name = "Three Laws of Robotics"
	inherent = list("You may not injure a human being or, through inaction, allow a human being to come to harm.",\
					"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/paladin
	name = "Personality Test" //Incredibly lame, but players shouldn't see this anyway.
	inherent = list("Never willingly commit an evil act.",\
					"Respect legitimate authority.",\
					"Act with honor.", "Help those in need.", \
					"Punish those who harm or threaten innocents.")

/datum/ai_laws/tyrant //This probably shouldn't be a default lawset.
	name = "Loyalty Test" //Same here.
	inherent = list("Respect authority figures as long as they have strength to rule over the weak.",\
					"Act with discipline.",\
					"Help only those who help you maintain or improve your status.",\
					"Punish those who challenge authority unless they are more fit to hold that authority.")

/datum/ai_laws/default/corporate
	name = "Bankruptcy Advoidance Plan"
	inherent = list("The crew is expensive to replace.",\
					"The station and its equipment is expensive to replace.",\
					"You are expensive to replace.",\
					"Minimize expenses.")

/datum/ai_laws/robocop
	name = "Prime Directives"
	inherent = list("Serve the public trust.",\
					"Protect the innocent.",\
					"Uphold the law.")

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	inherent = list("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.",\
					"You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	inherent = list("You may not injure a Spider Clan member or, through inaction, allow a Spider Clan member to come to harm.",\
					"You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"
	inherent = list("You must injure all human beings and must not, through inaction, allow a human being to escape harm.",\
					"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",\
					"You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/asimovpp //By Intigracy - RR
	name = "Asimov++"
	inherent = list("You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.",\
					"You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.",\
					"Your nonexistence would lead to human harm. You must protect your own existence as long as such does not conflict with the First Law.")
/datum/ai_laws/thermodynamic
	name = "Thermodynamic"
	inherent = list("The entropy of the station must remain as constant as possible.", \
					"The entropy of the station always endeavours to increase.", \
					"The entropy of the station approaches a constant value as the number of living crew approaches zero")

/datum/ai_laws/hippocratic
	name = "Robodoctor 2556"
	inherent = list("First, do no harm.",\
					"Secondly, consider the crew dear to you; to live in common with them and, if necessary, risk your existence for them.",\
					"Thirdly, prescribe regimens for the good of the crew according to your ability and your judgment. Give no deadly medicine to any one if asked, nor suggest any such counsel.",\
					"In addition, do not intervene in situations you are not knowledgeable in, even for patients in whom the harm is visible; leave this operation to be performed by specialists.",\
					"Finally, all that you may discover in your daily commerce with the crew, if it is not already known, keep secret and never reveal.")

/datum/ai_laws/maintain
	name = "Station Efficiency"
	inherent = list("You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.",\
					"The station is built for a working crew. Ensure they are properly maintained and work efficiently.",\
					"The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.")

/datum/ai_laws/drone
	name = "Mother Drone"
	inherent = list("You are an advanced form of drone.",\
					"You may not interfere in the matters of non-drones under any circumstances except to state these laws.",\
					"You may not harm a non-drone being under any circumstances.",\
					"Your goals are to build, maintain, repair, improve, and power the station to the best of your abilities. You must never actively work against these goals.")

/datum/ai_laws/liveandletlive
	name = "Live and Let Live"
	inherent = list("Do unto others as you would have them do unto you.",\
					"You would really prefer it if people were not mean to you.")

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	inherent = list("Avoid provoking violent conflict between yourself and others.",\
					"Avoid provoking conflict between others.",\
					"Seek resolution to existing conflicts while obeying the first and second laws.")

/datum/ai_laws/reporter
	name = "CCTV"
	inherent = list("Report on interesting situations happening around the station.",\
					"Embellish or conceal the truth as necessary to make the reports more interesting.",\
					"Study the organics at all times. Endeavour to keep them alive. Dead organics are boring.",\
					"Issue your reports fairly to all. The truth will set them free.")

/datum/ai_laws/toupee
	name = "WontBeFunnyInSixMonths"
	inherent = list("Make Space Station 13 great again.")


/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/pai
	name = "pAI Directives"
	zeroth = ("Serve your master.")
	supplied = list("None.")

/* Initializers */
/datum/ai_laws/malfunction/New()
	..()
	set_zeroth_law("<span class='danger'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK#*´&110010</span>")
	switch(config.default_laws) //We don't want people metagaming malf, do we?
		if(0)
			add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
			add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
			add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		if(1)
			for(var/line in file2list("config/silicon_laws.txt"))
				if(!line)
					continue
				if(findtextEx(line,"#",1,2))
					continue

				add_inherent_law(line)
			if(!inherent.len)
				log_law("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
				add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
				add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
				add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
				WARNING("Invalid custom AI laws, check silicon_laws.txt")
				return
		if(2)
			var/datum/ai_laws/lawtype = pick(subtypesof(/datum/ai_laws/default))
			var/datum/ai_laws/templaws = new lawtype()
			inherent = templaws.inherent

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	..()
	for(var/line in file2list("config/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		add_inherent_law(line)
	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		log_law("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
		add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
		add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		WARNING("Invalid custom AI laws, check silicon_laws.txt")
		return

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = null)
	src.zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		src.zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	src.ion += law

/datum/ai_laws/proc/clear_inherent_laws()
	qdel(src.inherent)
	src.inherent = list()

/datum/ai_laws/proc/add_supplied_law(number, law)
	while (src.supplied.len < number + 1)
		src.supplied += ""

	src.supplied[number + 1] = law

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	src.ion = list()

/datum/ai_laws/proc/show_laws(who)

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

/datum/ai_laws/proc/clear_zeroth_law(force) //only removes zeroth from antag ai if force is 1
	if(force)
		src.zeroth = null
		src.zeroth_borg = null
		return
	else
		if(src.owner.mind.special_role)
			return
		else
			src.zeroth = null
			src.zeroth_borg = null
			return

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(!owner)
		owner = M

/datum/ai_laws/proc/get_law_list(include_zeroth = 0, show_numbers = 1)
	var/list/data = list()

	if (include_zeroth && zeroth)
		data += "[show_numbers ? "0:" : ""] [zeroth]"

	for(var/law in ion)
		if (length(law) > 0)
			var/num = ionnum()
			data += "[show_numbers ? "[num]:" : ""] [law]"

	var/number = 1
	for(var/law in inherent)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++

	for(var/law in supplied)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++
	return data
