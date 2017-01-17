/datum/antagonist/team/cult
	var/datum/action/innate/cultcomm/communion = new

/datum/antagonist/team/cult/Destroy()
	qdel(communion)
	return ..()

/datum/antagonist/team/cult/on_gain()
	. = ..()
	if(!owner)
		return
	if(team)
		team.give_team_objectives(owner)
	if(jobban_isbanned(owner.current, ROLE_CULTIST))
		addtimer(ticker.mode, "replace_jobbaned_player", 0, TIMER_NORMAL, owner.current, ROLE_CULTIST, ROLE_CULTIST)
	owner.attack_log += "\[[time_stamp()]\] <font color=#960000>Has been converted to the cult of Nar'Sie!</font>"

/datum/antagonist/team/cult/apply_innate_effects()
	. = ..()
	owner.current.faction |= "cult"
	owner.current.verbs += /mob/living/proc/cult_help
	ticker.mode.update_cult_icons_added(owner)
	communion.Grant(owner)

/datum/antagonist/team/cult/remove_innate_effects()
	. = ..()
	owner.current.faction -= "cult"
	owner.current.verbs -= /mob/living/proc/cult_help
	ticker.mode.update_cult_icons_removed(owner)

/datum/antagonist/team/cult/on_removal()
	. = ..()
	owner << "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Dark One and all your memories as its servant.</span>"
	owner.attack_log += "\[[time_stamp()]\] <font color=#960000>Has renounced the cult of Nar'Sie!</font>"
	if(!silent)
		owner.current.visible_message("<span class='big'>[owner] looks like [owner.current.p_they()] just reverted to their old faith!</span>")
