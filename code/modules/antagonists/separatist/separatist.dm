/datum/team/nation
	name = "\improper Nation"
	member_name = "separatist"
	///a list of ranks that can join this nation.
	var/list/potential_recruits
	///department said team is related to
	var/datum/job_department/department
	///whether to forge objectives attacking other nations
	var/dangerous_nation = TRUE

/datum/team/nation/New(starting_members, potential_recruits, department)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(new_possible_separatist))
	src.potential_recruits = potential_recruits
	src.department = department

/datum/team/nation/Destroy(force)
	department = null
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	. = ..()

/**
 * Signal for adding new crewmembers (players joining the game) to the revolution.
 *
 * Arguments:
 * source: global signal, so this is SSdcs.
 * crewmember: new onboarding crewmember.
 * rank: new crewmember's rank.
 */
/datum/team/nation/proc/new_possible_separatist(datum/source, mob/living/crewmember, rank)
	SIGNAL_HANDLER

	if(rank in potential_recruits)
		//surely we can trust the player who just joined the game to have a mind.
		crewmember.mind.add_antag_datum(/datum/antagonist/separatist,src)

/**
 * Called by department revolt event to give the team some objectives.
 *
 * Arguments:
 * dangerous_nation: whether this nation will get objectives that are very very bloodthirsty, like killing other departments.
 * target_nation: string of the nation they need to destroy/befriend
 */
/datum/team/nation/proc/generate_nation_objectives(are_we_hostile = TRUE, datum/team/nation/target_nation)

	var/datum/objective/fluff
	if(istype(department, /datum/job_department/silicon))
		// snowflake but silicons have their own goals
		fluff = new /datum/objective/united_nations()

	else
		dangerous_nation = are_we_hostile
		if(dangerous_nation && target_nation)
			var/datum/objective/destroy = new /datum/objective/destroy_nation(null, target_nation)
			destroy.team = src
			objectives += destroy
			target_nation.war_declared(src) //they need to possibly get an objective back
		fluff = new /datum/objective/separatist_fluff(null, name)

	fluff.team = src
	objectives += fluff
	update_all_member_objectives()

/datum/team/nation/proc/war_declared(datum/team/nation/attacking_nation)
	if(!dangerous_nation) //peaceful nations do not wish to strike back
		return
	//otherwise, lets add an objective to strike them back
	var/datum/objective/destroy = new /datum/objective/destroy_nation(null, attacking_nation)
	destroy.team = src
	objectives += destroy
	update_all_member_objectives(span_danger("The nation of [attacking_nation] has declared the intent to conquer [src]! You have new objectives."))

/datum/team/nation/proc/update_all_member_objectives(message)
	for(var/datum/mind/member in members)
		var/datum/antagonist/separatist/needs_objectives = member.has_antag_datum(/datum/antagonist/separatist)
		needs_objectives.objectives |= objectives
		if(message)
			to_chat(member.current, message)
		needs_objectives.owner.announce_objectives()

/datum/antagonist/separatist
	name = "\improper Separatists"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	suicide_cry = "FOR THE MOTHERLAND!!"
	ui_name = "AntagInfoSeparatist"
	///team datum
	var/datum/team/nation/nation
	///background color of the ui
	var/ui_color

/datum/antagonist/separatist/on_gain()
	create_objectives()
	setup_ui_color()
	. = ..()

//give ais their role as UN
/datum/antagonist/separatist/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/silicon/ai/united_nations_ai = mob_override || owner.current
	if(!isAI(united_nations_ai))
		return
	united_nations_ai.no_law_rack_link = TRUE
	united_nations_ai.replace_law_set(/datum/ai_laws/united_nations)

/datum/antagonist/separatist/on_removal()
	remove_objectives()
	. = ..()

/datum/antagonist/separatist/proc/create_objectives()
	objectives |= nation.objectives

/datum/antagonist/separatist/proc/remove_objectives()
	objectives -= nation.objectives

/datum/antagonist/separatist/proc/setup_ui_color()
	var/list/hsl = rgb2num(nation.department.ui_color, COLORSPACE_HSL)
	hsl[3] = 25 //setting lightness very low
	ui_color = rgb(hsl[1], hsl[2], hsl[3], space = COLORSPACE_HSL)

/datum/antagonist/separatist/create_team(datum/team/nation/new_team)
	if(!new_team)
		return
	nation = new_team

/datum/antagonist/separatist/get_team()
	return nation

/datum/antagonist/separatist/ui_static_data(mob/user)
	var/list/data = list()
	data["objectives"] = get_objectives()
	data["nation"] = nation.name
	data["nationColor"] = ui_color
	return data
