/datum/team/nation
	name = "Nation"
	member_name = "separatist"
	///a list of ranks that can join this nation.
	var/list/potential_recruits
	///checked by the department revolt event to prevent trying to make a nation that is already independent... double independent.
	var/nation_department
	var/dangerous_nation = TRUE

/datum/team/nation/New(starting_members, _potential_recruits, _nation_department)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, .proc/new_possible_separatist)
	potential_recruits = _potential_recruits
	nation_department = _nation_department

/datum/team/nation/Destroy(force, ...)
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
	dangerous_nation = are_we_hostile
	if(dangerous_nation && target_nation)
		var/datum/objective/destroy = new /datum/objective/destroy_nation(null, target_nation)
		destroy.team = src
		objectives += destroy
		target_nation.war_declared(src) //they need to possibly get an objective back
	var/datum/objective/fluff = new /datum/objective/separatist_fluff(null, name)
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
	update_all_member_objectives("<span class='danger'>The nation of [attacking_nation] has declared the intent to conquer [src]! You have new objectives.</span>")

/datum/team/nation/proc/update_all_member_objectives(message)
	for(var/datum/mind/member in members)
		var/datum/antagonist/separatist/needs_objectives = member.has_antag_datum(/datum/antagonist/separatist)
		needs_objectives.objectives |= objectives
		if(message)
			to_chat(member.current, message)
		needs_objectives.owner.announce_objectives()

/datum/antagonist/separatist
	name = "Separatists"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nation

/datum/antagonist/separatist/on_gain()
	create_objectives()
	. = ..()

/datum/antagonist/separatist/on_removal()
	remove_objectives()
	. = ..()

/datum/antagonist/separatist/proc/create_objectives()
	objectives |= nation.objectives

/datum/antagonist/separatist/proc/remove_objectives()
	objectives -= nation.objectives

/datum/antagonist/separatist/create_team(datum/team/nation/new_team)
	if(!new_team)
		return
	nation = new_team

/datum/antagonist/separatist/get_team()
	return nation

/datum/antagonist/separatist/greet()
	to_chat(owner, "<span class='boldannounce'>You are a separatist for an independent [nation.nation_department]! [nation.name] forever! Protect the sovereignty of your newfound land with your comrades (fellow department members) in arms!</span>")
	owner.announce_objectives()

//objectives
/datum/objective/destroy_nation
	name = "nation destruction"
	explanation_text = "Make sure no member of the enemy nation escapes alive!"
	team_explanation_text = "Make sure no member of the enemy nation escapes alive!"
	var/datum/team/nation/target_team

/datum/objective/destroy_nation/update_explanation_text()
	. = ..()
	if(target_team)
		explanation_text = "Make sure no member of [target_team] ([target_team.nation_department]) nation escapes alive!"
	else
		explanation_text = "Free Objective"

/datum/objective/destroy_nation/New(text, target_department)
	. = ..()
	target_team = target_department
	update_explanation_text()

/datum/objective/destroy_nation/check_completion()
	if(!target_team)
		return TRUE

	for(var/datum/antagonist/separatist/separatist_datum in GLOB.antagonists)
		if(separatist_datum.nation.nation_department != target_team.nation_department) //a separatist, but not one part of the department we need to destroy
			continue
		var/datum/mind/target = separatist_datum.owner
		if(target && considered_alive(target) && (target.current.onCentCom() || target.current.onSyndieBase()))
			return FALSE //at least one member got away
	return TRUE

/datum/objective/separatist_fluff

/datum/objective/separatist_fluff/New(text, nation_name)
	var/list/explanationTexts = list(
		"The rest of the station must be taxed for their use of [nation_name]'s services.", \
		"Make statues everywhere of your glorious leader of [nation_name]. If you have nobody, crown one amongst yourselves!", \
		"[nation_name] must be absolutely blinged out.", \
		"Damage as much of the station as you can, keep it in disrepair. [nation_name] must be the untouched paragon!", \
		"Heavily reinforce [nation_name] against the dangers of the outside world.", \
		"Make sure [nation_name] is fully off the grid, not requiring power or any other services from other departments!", \
		"Use a misaligned teleporter to make you and your fellow citizens of [nation_name] flypeople. Bring toxin medication!", \
		"Save the station when it needs you most. [nation_name] will be remembered as the protectors.", \
		"Arm up. The citizens of [nation_name] have a right to bear arms.",
	)
	explanation_text = pick(explanationTexts)
	..()

/datum/objective/separatist_fluff/check_completion()
	return TRUE
