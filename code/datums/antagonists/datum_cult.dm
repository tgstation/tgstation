/datum/antagonist/cultist
	prevented_antag_datum_types = list(/datum/antagonist/clockcultist)
	gain_fluff = "<span class='cultitalic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been \
	torn open and something evil takes root.<br>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve the Geometer above all else. \
	Bring It back.</b></span>"
	loss_fluff = "<span class='userdanger'>An unfamiliar white light courses through your mind, cleansing the Geometer's taint and all your memories of your time as its servant.</span>"
	var/datum/action/innate/cultcomm/communion = new()

/datum/antagonist/cultist/Destroy()
	qdel(communion)
	return ..()

/datum/antagonist/cultist/can_be_owned(mob/living/new_body)
	. = ..()
	if(.)
		. = is_convertable_to_cult(new_body)

/datum/antagonist/cultist/on_gain()
	if(ticker && ticker.mode && owner.mind)
		ticker.mode.cult += owner.mind
		ticker.mode.update_cult_icons_added(owner.mind)
		if(istype(ticker.mode, /datum/game_mode/cult))
			var/datum/game_mode/cult/C = ticker.mode
			C.memorize_cult_objectives(owner.mind)
		if(jobban_isbanned(owner, ROLE_CULTIST))
			addtimer(ticker.mode, "replace_jobbaned_player", 0, FALSE, owner, ROLE_CULTIST, ROLE_CULTIST)
	if(owner.mind)
		owner.mind.special_role = "Cultist"
	owner.attack_log += "\[[time_stamp()]\] <span class='cult'>Has been converted to the cult of Nar'Sie!</span>"
	..()

/datum/antagonist/cultist/apply_innate_effects()
	owner.faction |= "cult"
	owner.verbs += /mob/living/proc/cult_help
	communion.Grant(owner)
	..()

/datum/antagonist/cultist/remove_innate_effects()
	owner.faction -= "cult"
	owner.verbs -= /mob/living/proc/cult_help
	..()

/datum/antagonist/cultist/on_remove()
	if(owner.mind)
		owner.mind.wipe_memory()
		if(ticker && ticker.mode)
			ticker.mode.cult -= owner.mind
			ticker.mode.update_cult_icons_removed(owner.mind)
	owner.attack_log += "\[[time_stamp()]\] <span class='cult'>Has renounced the cult of Nar'Sie!</span>"
	if(!silent_update)
		owner.visible_message("<span class='big'>[owner] looks like they just reverted to their old faith!</span>")
	..()
