/datum/antagonist/cult
	var/datum/action/innate/cultcomm/communion = new

/datum/antagonist/cult/Destroy()
	qdel(communion)
	return ..()

/datum/antagonist/cult/on_gain()
	. = ..()
	if(!owner)
		return
	if(jobban_isbanned(owner.current, ROLE_CULTIST))
		addtimer(CALLBACK(SSticker.mode, /datum/game_mode.proc/replace_jobbaned_player, owner.current, ROLE_CULTIST, ROLE_CULTIST), 0)
	SSticker.mode.update_cult_icons_added(owner)
	owner.current.log_message("<font color=#960000>Has been converted to the cult of Nar'Sie!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction |= "cult"
	current.verbs += /mob/living/proc/cult_help
	communion.Grant(current)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction -= "cult"
	current.verbs -= /mob/living/proc/cult_help
	communion.Remove(current)

/datum/antagonist/cult/on_removal()
	. = ..()
	SSticker.mode.update_cult_icons_removed(owner)
	to_chat(owner, "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Dark One and all your memories as its servant.</span>")
	owner.current.log_message("<font color=#960000>Has renounced the cult of Nar'Sie!</font>", INDIVIDUAL_ATTACK_LOG)
	if(!silent)
		owner.current.visible_message("<span class='big'>[owner] looks like [owner.current.p_they()] just reverted to their old faith!</span>")
