/datum/team/nation
	name = "Nation"
	member_name = "separatist"
	///a list of ranks that can join this nation.
	var/list/potential_recruits

/datum/team/nation/New(starting_members, _potential_recruits)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, .proc/new_possible_separatist)
	potential_recruits = _potential_recruits

/datum/team/nation/Destroy(force, ...)
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	. = ..()

/datum/team/nation/proc/new_possible_separatist(mob/living/crewmember, rank)
	if(rank in potential_recruits)
		//surely we can trust the player who just joined the game to have a mind.
		living.mind.add_antag_datum(/datum/antagonist/separatist,src)

/datum/antagonist/separatist
	name = "Separatists"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nation

/datum/antagonist/separatist/create_team(datum/team/nation/new_team)
	if(!new_team)
		return
	nation = new_team

/datum/antagonist/separatist/get_team()
	return nation

/datum/antagonist/separatist/greet()
	to_chat(owner, "<span class='userdanger'>You are a separatist for an independent department! [nation.name] forever! Protect the sovereignty of your newfound land with your comrades (fellow department members) in arms!</span>")
