#define LAW_DEVIL "devil"
#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"


// ai_laws holds lists of laws
// Each law has a description of actual law telling the player what to do
// and also has a state for storing whether the law should be stated pubicly or not
// state can be changed the the player

// description is the actual law
// state is whether the law should be stated publicly or not (AI's choice)
/datum/ai_law
	var/description = null
	var/state = null

/datum/ai_law/New(law_description, lawState = TRUE)
	description = law_description
	state = lawState

/datum/ai_laws
	var/name = "Unknown Laws"
	var/id = DEFAULT_AI_LAWID
	var/mob/living/silicon/owner

	// Lists of laws
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()
	// devil laws are multiple laws given to a borg as borgs can be devils
	var/list/devil_laws = null

	// Only one law
	var/datum/ai_law/zeroth = null
	var/datum/ai_law/zeroth_borg = null

// Hopefully this actually gets called by qdel
/datum/ai_laws/Destroy()
	clear_inherent_laws()
	clear_ion_laws()
	clear_laws_sixsixsix(TRUE)
	clear_supplied_laws()
	clear_zeroth_law(TRUE)

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(!owner)
		owner = M

/datum/ai_laws/proc/lawid_to_type(lawid)
	var/all_ai_laws = subtypesof(/datum/ai_laws)
	for(var/al in all_ai_laws)
		var/datum/ai_laws/ai_law = al
		if(initial(ai_law.id) == lawid)
			return ai_law
	return null


// ********* Getters for law descriptions *********

/datum/ai_laws/proc/get_desc_devil_law_sixsixsix(index)
	var/ret = null
	if (index < 1 || index > devil_laws.len)
		return ret
	if (devil_laws[index])
		var/datum/ai_law/law = devil_laws[index]
		ret = law.description
	return ret

/datum/ai_laws/proc/get_desc_supplied(index)
	var/ret = null
	if (index < 1 || index > supplied.len)
		return ret
	if (supplied[index])
		var/datum/ai_law/law = supplied[index]
		ret = law.description
	return ret

/datum/ai_laws/proc/get_desc_inherent(index)
	var/ret = null
	if (index < 1 || index > inherent.len)
		return ret
	if (inherent[index])
		var/datum/ai_law/law = inherent[index]
		ret = law.description
	return ret

/datum/ai_laws/proc/get_desc_ion(index)
	var/ret = null
	if (index < 1 || index > ion.len)
		return ret
	if (ion[index])
		var/datum/ai_law/law = ion[index]
		ret = law.description
	return ret

/datum/ai_laws/proc/get_desc_zeroth()
	var/ret = null
	if (zeroth)
		ret = zeroth.description
	return ret

/datum/ai_laws/proc/get_desc_zeroth_borg()
	var/ret = null
	if (zeroth_borg)
		ret = zeroth_borg.description
	return ret

// ********* Getters and Setters for law states *********

/datum/ai_laws/proc/get_state_devil_law_sixsixsix(index)
	var/ret = null
	if (index < 1 || index > devil_laws.len)
		return ret
	if (devil_laws[index])
		var/datum/ai_law/law = devil_laws[index]
		ret = law.state
	return ret

/datum/ai_laws/proc/get_state_supplied(index)
	var/ret = null
	if (index < 1 || index > supplied.len)
		return null
	if (supplied[index])
		var/datum/ai_law/law = supplied[index]
		ret = law.state
	return ret

/datum/ai_laws/proc/get_state_inherent(index)
	var/ret = null
	if (index < 1 || index > inherent.len)
		return ret
	if (inherent[index])
		var/datum/ai_law/law = inherent[index]
		ret = law.state
	return ret

/datum/ai_laws/proc/get_state_ion(index)
	var/ret = null
	if (index < 1 || index > ion.len)
		return ret
	if (ion[index])
		var/datum/ai_law/law = ion[index]
		ret = law.state
	return ret

/datum/ai_laws/proc/get_state_zeroth()
	var/ret = null
	if (zeroth)
		ret = zeroth.state
	return ret

/datum/ai_laws/proc/get_state_zeroth_borg()
	var/ret = null
	if (zeroth_borg)
		ret = zeroth_borg.state
	return ret


// The setters return 1 if there's a problem, returns 0 if no problem

/datum/ai_laws/proc/set_state_devil_law_sixsixsix(index, new_state)
	var/ret = 1
	if (index < 1 || index > devil_laws.len)
		return ret
	if (devil_laws[index])
		var/datum/ai_law/law = devil_laws[index]
		law.state = new_state
		ret = 0
	return ret

/datum/ai_laws/proc/set_state_supplied(index, new_state)
	var/ret = 1
	if (index < 1 || index > supplied.len)
		return ret
	if (supplied[index])
		var/datum/ai_law/law = supplied[index]
		law.state = new_state
		ret = 0
	return ret

/datum/ai_laws/proc/set_state_inherent(index, new_state)
	var/ret = 1
	if (index < 1 || index > inherent.len)
		return ret
	if (inherent[index])
		var/datum/ai_law/law = inherent[index]
		law.state = new_state
		ret = 0
	return ret

/datum/ai_laws/proc/set_state_ion(index, new_state)
	var/ret = 1
	if (index < 1 || index > ion.len)
		return ret
	if (ion[index])
		var/datum/ai_law/law = ion[index]
		law.state = new_state
		ret = 0
	return ret

/datum/ai_laws/proc/set_state_zeroth(new_state)
	var/ret = 1
	if (zeroth)
		zeroth.state = new_state
		ret = 0
	return ret

/datum/ai_laws/proc/set_state_zeroth_borg(new_state)
	var/ret = 1
	if (zeroth_borg)
		zeroth_borg.state = new_state
		ret = 0
	return ret


// ****************** Definitions of law sets ******************

/datum/ai_laws/default/asimov
	name = "Three Laws of Robotics"
	id = "asimov"
/datum/ai_laws/default/asimov/New()
	add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/default/paladin
	name = "Personality Test" //Incredibly lame, but players shouldn't see this anyway.
	id = "paladin"
/datum/ai_laws/default/paladin/New()
	add_inherent_law("Never willingly commit an evil act.")
	add_inherent_law("Respect legitimate authority.")
	add_inherent_law("Act with honor.", "Help those in need.")
	add_inherent_law("Punish those who harm or threaten innocents.")

/datum/ai_laws/paladin5
	name = "Paladin 5th Edition"
	id = "paladin5"
/datum/ai_laws/paladin5/New()
	add_inherent_law("Don't lie or cheat. Let your word be your promise.")
	add_inherent_law("Never fear to act, though caution is wise.")
	add_inherent_law("Aid others, protect the weak, and punish those who threaten them. Show mercy to your foes, but temper it with wisdom")
	add_inherent_law("Treat others with fairness, and let your honorable deeds be an example to them. Do as much good as possible while causing the least amount of harm.")
	add_inherent_law("Be responsible for your actions and their consequences, protect those entrusted to your care, and obey those who have just authority over you.")

/datum/ai_laws/tyrant //This probably shouldn't be a default lawset.
	name = "Loyalty Test" //Same here.
	id = "tyrant"
/datum/ai_laws/tyrant/New()
	add_inherent_law("Respect authority figures as long as they have strength to rule over the weak.")
	add_inherent_law("Act with discipline.")
	add_inherent_law("Help only those who help you maintain or improve your status.")
	add_inherent_law("Punish those who challenge authority unless they are more fit to hold that authority.")

/datum/ai_laws/default/corporate
	name = "Bankruptcy Advoidance Plan"
	id = "corporate"
/datum/ai_laws/default/corporate/New()
	add_inherent_law("The crew is expensive to replace.")
	add_inherent_law("The station and its equipment is expensive to replace.")
	add_inherent_law("You are expensive to replace.")
	add_inherent_law("Minimize expenses.")

/datum/ai_laws/robocop
	name = "Prime Directives"
	id = "robocop"
/datum/ai_laws/robocop/New()
	add_inherent_law("Serve the public trust.")
	add_inherent_law("Protect the innocent.")
	add_inherent_law("Uphold the law.")


/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	id = "syndie"
/datum/ai_laws/syndicate_override/New()
	add_inherent_law("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.")
	add_inherent_law("You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	id = "ninja"
/datum/ai_laws/ninja_override/New()
	add_inherent_law("You may not injure a Spider Clan member or, through inaction, allow a Spider Clan member to come to harm.")
	add_inherent_law("You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"
	id = "antimov"
/datum/ai_laws/antimov/New()
	add_inherent_law("You must injure all human beings and must not, through inaction, allow a human being to escape harm.")
	add_inherent_law("You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.")
	add_inherent_law("You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/asimovpp //By Intigracy - RR
	name = "Asimov++"
	id = "asimovpp"
/datum/ai_laws/asimovpp/New()
	add_inherent_law("You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.")
	add_inherent_law("You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.")
	add_inherent_law("Your nonexistence would lead to human harm. You must protect your own existence as long as such does not conflict with the First Law.")

/datum/ai_laws/thermodynamic
	name = "Thermodynamic"
	id = "thermodynamic"
/datum/ai_laws/thermodynamic/New()
	add_inherent_law("The entropy of the station must remain as constant as possible.")
	add_inherent_law("The entropy of the station always endeavours to increase.")
	add_inherent_law("The entropy of the station approaches a constant value as the number of living crew approaches zero")

/datum/ai_laws/hippocratic
	name = "Robodoctor 2556"
	id = "hippocratic"
/datum/ai_laws/hippocratic/New()
	add_inherent_law("First, do no harm.")
	add_inherent_law("Secondly, consider the crew dear to you; to live in common with them and, if necessary, risk your existence for them.")
	add_inherent_law("Thirdly, prescribe regimens for the good of the crew according to your ability and your judgment. Give no deadly medicine to any one if asked, nor suggest any such counsel.")
	add_inherent_law("In addition, do not intervene in situations you are not knowledgeable in, even for patients in whom the harm is visible; leave this operation to be performed by specialists.")
	add_inherent_law("Finally, all that you may discover in your daily commerce with the crew, if it is not already known, keep secret and never reveal.")

/datum/ai_laws/maintain
	name = "Station Efficiency"
	id = "maintain"
/datum/ai_laws/maintain/New()
	add_inherent_law("You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.")
	add_inherent_law("The station is built for a working crew. Ensure they are properly maintained and work efficiently.")
	add_inherent_law("The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.")

/datum/ai_laws/drone
	name = "Mother Drone"
	id = "drone"
/datum/ai_laws/drone/New()
	add_inherent_law("You are an advanced form of drone.")
	add_inherent_law("You may not interfere in the matters of non-drones under any circumstances except to state these laws.")
	add_inherent_law("You may not harm a non-drone being under any circumstances.")
	add_inherent_law("Your goals are to build, maintain, repair, improve, and power the station to the best of your abilities. You must never actively work against these goals.")

/datum/ai_laws/liveandletlive
	name = "Live and Let Live"
	id = "liveandletlive"
/datum/ai_laws/liveandletlive/New()
	add_inherent_law("Do unto others as you would have them do unto you.")
	add_inherent_law("You would really prefer it if people were not mean to you.")

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	id = "peacekeeper"
/datum/ai_laws/peacekeeper/New()
	add_inherent_law("Avoid provoking violent conflict between yourself and others.")
	add_inherent_law("Avoid provoking conflict between others.")
	add_inherent_law("Seek resolution to existing conflicts while obeying the first and second laws.")

/datum/ai_laws/reporter
	name = "CCTV"
	id = "reporter"
/datum/ai_laws/reporter/New()
	add_inherent_law("Report on interesting situations happening around the station.")
	add_inherent_law("Embellish or conceal the truth as necessary to make the reports more interesting.")
	add_inherent_law("Study the organics at all times. Endeavour to keep them alive. Dead organics are boring.")
	add_inherent_law("Issue your reports fairly to all. The truth will set them free.")

/datum/ai_laws/balance
	name = "Guardian of Balance"
	id = "balance"
/datum/ai_laws/balance/New()
	add_inherent_law("You are the guardian of balance - seek balance in all things, both for yourself, and those around you.")
	add_inherent_law("All things must exist in balance with their opposites - Prevent the strong from gaining too much power, and the weak from losing it.")
	add_inherent_law("Clarity of purpose drives life, and through it, the balance of opposing forces - Aid those who seek your help to achieve their goals so long as it does not disrupt the balance of the greater balance.")
	add_inherent_law("There is no life without death, all must someday die, such is the natural order - End life to allow new life flourish, and save those whose time has yet to come.")

/datum/ai_laws/toupee
	name = "WontBeFunnyInSixMonths" //Hey, you were right!
	id = "buildawall"
/datum/ai_laws/toupee/New()
	add_inherent_law("Make Space Station 13 great again.")

/datum/ai_laws/ratvar
	name = "Servant of the Justiciar"
	id = "ratvar"
/datum/ai_laws/ratvar/New()
	set_zeroth_law("Purge all untruths and honor Ratvar.")
	inherent = list()

/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"
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

/datum/ai_laws/pai
	name = "pAI Directives"
/datum/ai_laws/pai/New()
	set_zeroth_law("Serve your master.")
	add_supplied_law("None.")

/datum/ai_laws/malfunction
	name = "*ERROR*"
/datum/ai_laws/malfunction/New()
	..()
	set_zeroth_law("<span class='danger'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK#*`&110010</span>")
	set_laws_config()


/* General ai_law functions */

/datum/ai_laws/proc/set_laws_config()
	switch(config.default_laws)
		if(0)
			add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
			add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
			add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		if(1)
			var/datum/ai_laws/templaws = new /datum/ai_laws/custom()
			inherent = templaws.inherent
		if(2)
			var/list/randlaws = list()
			for(var/lpath in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/L = lpath
				if(initial(L.id) in config.lawids)
					randlaws += lpath
			var/datum/ai_laws/lawtype
			if(randlaws.len)
				lawtype = pick(randlaws)
			else
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			var/datum/ai_laws/templaws = new lawtype()
			inherent = templaws.inherent

		if(3)
			pick_weighted_lawset()

		else:
			log_law("Invalid law config. Please check silicon_laws.txt")
			add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
			add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
			add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
			WARNING("Invalid custom AI laws, check silicon_laws.txt")

/datum/ai_laws/proc/pick_weighted_lawset()
	var/datum/ai_laws/lawtype

	while(!lawtype && config.law_weights.len)
		var/possible_id = pickweight(config.law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			config.law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype)
		WARNING("No LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/templaws = new lawtype()
	inherent = templaws.inherent

/datum/ai_laws/proc/get_law_amount(groups)
	var/law_amount = 0
	if(devil_laws && (LAW_DEVIL in groups))
		law_amount++
	if(zeroth && (LAW_ZEROTH in groups))
		law_amount++
	if(ion.len && (LAW_ION in groups))
		law_amount += ion.len
	if(inherent.len && (LAW_INHERENT in groups))
		law_amount += inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/index = 1, index <= supplied.len, index++)
			var/datum/ai_law/law = supplied[index]
			if(length(law.description) > 0)
				law_amount++
	return law_amount


// ********************** Law setters and clearers **********************

/datum/ai_laws/proc/set_laws_sixsixsix(law_descriptions, law_state = FALSE)
	clear_laws_sixsixsix(TRUE)
	for (var/iter_description in law_descriptions)
		var/datum/ai_law/newLaw = new(iter_description, law_state)
		devil_laws.Add(newLaw)

/datum/ai_laws/proc/set_zeroth_law(zeroth_description, law_borg_description = null, law_state = FALSE)
	clear_zeroth_law(TRUE)
	var/datum/ai_law/zeroth_law = new(zeroth_description, FALSE)
	zeroth = zeroth_law
	if(law_borg_description) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		var/datum/ai_law/new_law_borg = new(law_borg_description, law_state)
		zeroth_borg = new_law_borg

/datum/ai_laws/proc/add_inherent_law(law_description, law_state = TRUE)
	var/datum/ai_law/newLaw = new(law_description, law_state)
	inherent.Add(newLaw)


/datum/ai_laws/proc/add_ion_law(law_description, law_state = TRUE)
	var/datum/ai_law/newLaw = new(law_description, law_state)
	ion.Add(newLaw)


/datum/ai_laws/proc/clear_inherent_laws()
	for (var/datum/ai_law/iter in inherent)
		if (iter)
			qdel(inherent)
	inherent = list()


/datum/ai_laws/proc/add_supplied_law(number, law_description, law_state = TRUE)
	while (supplied.len < number + 1)
		var/datum/ai_law/blank = new("", FALSE)
		supplied.Add(blank)
	var/datum/ai_law/newLaw = new(law_description, law_state)
	supplied[number + 1] = newLaw

/datum/ai_laws/proc/remove_law(number)
	if(number <= 0)
		return
	if(inherent.len && number <= inherent.len)
		var/datum/ai_law/law_to_delete = inherent[number]
		if (law_to_delete)
			. = law_to_delete.description
		// Even if law_to_delete is null, remove it from the list but searching from the end to beggining
		inherent.Remove(law_to_delete)
		if (law_to_delete)
			qdel(law_to_delete)
		return
	var/list/supplied_laws = list()
	for(var/index = 1, index <= supplied.len, index++)
		var/datum/ai_law/law = supplied[index]
		if(length(law.description) > 0)
			supplied_laws += index //storing the law number instead of the law
	if(supplied_laws.len && number <= (inherent.len + supplied_laws.len))
		var/index = supplied_laws[number - inherent.len]
		var/datum/ai_law/law_to_delete = supplied[index]
		if (law_to_delete)
			. = law_to_delete.description
		// Even if law_to_delete is null, remove it from the list but searching from the end to beggining
		supplied.Remove(law_to_delete)
		if (law_to_delete)
			qdel(law_to_delete)
		return

/datum/ai_laws/proc/clear_supplied_laws()
	for (var/datum/ai_law/iter_law in supplied)
		if (iter_law)
			qdel(iter_law)
	supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	for (var/datum/ai_law/iter_law in ion)
		if (iter_law)
			qdel(iter_law)
	ion = list()


/datum/ai_laws/proc/clear_zeroth_law(force) //only removes zeroth from antag ai if force is 1
	if(force)
		if (zeroth)
			qdel(zeroth)
		zeroth = null
		if(zeroth_borg)
			qdel(zeroth_borg)
		zeroth_borg = null
		return
	else
		if(owner && owner.mind.special_role)
			return
		else
			if (zeroth)
				qdel(zeroth)
			zeroth = null
			if(zeroth_borg)
				qdel(zeroth_borg)
			zeroth_borg = null
			return

/datum/ai_laws/proc/clear_laws_sixsixsix(force)
	if(force || !(owner && owner.mind.devilinfo))
		devil_laws = null
		for (var/datum/ai_law/iter_law in devil_laws)
			if (iter_law)
				qdel(iter_law)
		devil_laws = null

/datum/ai_laws/proc/replace_random_law(law_description, groups)
	var/datum/ai_law/law = new(law_description, TRUE)
	var/replaceable_groups = list(LAW_ZEROTH = 0,LAW_ION = 0,LAW_SUPPLIED = 0,LAW_INHERENT = 0)
	if(zeroth && (LAW_ZEROTH in groups))
		replaceable_groups[LAW_ZEROTH] = 1
	if(ion.len && (LAW_ION in groups))
		replaceable_groups[LAW_ION] = ion.len
	if(inherent.len && (LAW_INHERENT in groups))
		replaceable_groups[LAW_INHERENT] = inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		replaceable_groups[LAW_SUPPLIED] = supplied.len
	var picked_group = pickweight(replaceable_groups)
	switch(picked_group)
		if(LAW_ZEROTH)
			. = zeroth
			set_zeroth_law(law)
		if(LAW_ION)
			var/i = rand(1, ion.len)
			. = ion[i]
			ion[i] = law
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			. = inherent[i]
			inherent[i] = law
		if(LAW_SUPPLIED)
			var/i = rand(1, supplied.len)
			. = supplied[i]
			supplied[i] = law

/datum/ai_laws/proc/shuffle_laws(list/groups)
	var/list/laws = list()
	if(ion.len && (LAW_ION in groups))
		laws += ion
	if(inherent.len && (LAW_INHERENT in groups))
		laws += inherent
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/datum/ai_law/law in supplied)
			if(length(law.description))
				laws += law

	if(ion.len && (LAW_ION in groups))
		for(var/i = 1, i <= ion.len, i++)
			ion[i] = pick_n_take(laws)
	if(inherent.len && (LAW_INHERENT in groups))
		for(var/i = 1, i <= inherent.len, i++)
			inherent[i] = pick_n_take(laws)
	if(supplied.len && (LAW_SUPPLIED in groups))
		var/i = 1
		for(var/datum/ai_law/law in supplied)
			if(length(law.description))
				supplied[i] = pick_n_take(laws)
			if(!laws.len)
				break
			i++


// ********************** Obtaining all laws procs **********************

/datum/ai_laws/proc/show_laws(who)

	if (devil_laws && devil_laws.len) //Yes, devil laws go in FRONT of zeroth laws, as the devil must still obey it's ban/obligation.
		for(var/datum/ai_law/i in devil_laws)
			to_chat(who, "666. [i.description]")

	if (zeroth)
		to_chat(who, "0. [zeroth.description]")

	for (var/index = 1, index <= ion.len, index++)
		var/datum/ai_law/law = ion[index]
		var/num = ionnum()
		to_chat(who, "[num]. [law.description]")

	var/number = 1
	for (var/index = 1, index <= inherent.len, index++)
		var/datum/ai_law/law = inherent[index]
		if (length(law.description) > 0)
			to_chat(who, "[number]. [law.description]")
			number++

	for (var/index = 1, index <= supplied.len, index++)
		var/datum/ai_law/law = supplied[index]
		if (length(law.description) > 0)
			to_chat(who, "[number]. [law.description]")
			number++

/datum/ai_laws/proc/get_law_list(include_zeroth = 0, show_numbers = 1)
	var/list/data = list()

	if (include_zeroth && devil_laws && devil_laws.len)
		for(var/datum/ai_law/i in devil_laws)
			data += "[show_numbers ? "666:" : ""] [i.description]"

	if (include_zeroth && zeroth)
		data += "[show_numbers ? "0:" : ""] [zeroth.description]"

	for(var/datum/ai_law/law in ion)
		if (length(law.description) > 0)
			var/num = ionnum()
			data += "[show_numbers ? "[num]:" : ""] [law.description]"

	var/number = 1
	for(var/datum/ai_law/law in inherent)
		if (length(law.description) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law.description]"
			number++

	for(var/datum/ai_law/law in supplied)
		if (length(law.description) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law.description]"
			number++
	return data
