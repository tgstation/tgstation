/datum/team/nation
	name = "\improper Nation"
	member_name = "separatist"
	///a list of ranks that can join this nation.
	var/list/potential_recruits
	///department said team is related to
	var/datum/job_department/department

/datum/team/nation/New(potential_recruits, department)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(new_possible_separatist))
	src.potential_recruits = potential_recruits
	src.department = department

/datum/team/nation/Destroy(force, ...)
	department = null
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

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
		crewmember.mind.add_antag_datum(/datum/antagonist/separatist, src)

/**
 * Called by department revolt event to give the team some objectives.
 *
 * Arguments:
 * target_nation: list of nations that they need to destroy
 */
/datum/team/nation/proc/generate_nation_objectives(list/target_nations)
	for(var/datum/team/nation/individual_nations as anything in target_nations)
		var/datum/objective/destroy = new /datum/objective/destroy_nation(null, individual_nations)
		destroy.team = src
		objectives += destroy
		individual_nations.war_declared(src) //they need to possibly get an objective back
	var/datum/objective/fluff = new /datum/objective/separatist_fluff(null, name)
	fluff.team = src
	objectives += fluff
	update_all_member_objectives()

/**
 * Called when a department declares war on us, this is the response.
 *
 * Arguments:
 * attacking_nation - The nation that's attacking us.
 */
/datum/team/nation/proc/war_declared(datum/team/nation/attacking_nation)
	//otherwise, lets add an objective to strike them back
	var/datum/objective/destroy = new /datum/objective/destroy_nation(null, attacking_nation)
	destroy.team = src
	objectives += destroy
	update_all_member_objectives(span_danger("The nation of [attacking_nation] has declared the intent to conquer [src]! You have new objectives."))

/datum/team/nation/proc/update_all_member_objectives(message)
	for(var/datum/mind/member as anything in members)
		var/datum/antagonist/separatist/needs_objectives = member.has_antag_datum(/datum/antagonist/separatist)
		needs_objectives.objectives = objectives
		if(message)
			to_chat(member.current, message)
		needs_objectives.owner.announce_objectives()
