/datum/antagonist/cultist
	prevented_antag_datum_type = /datum/antagonist/cultist
	some_flufftext = null
	var/datum/action/innate/cultcomm/communion = new()

/datum/antagonist/cultist/Destroy()
	qdel(communion)
	return ..()

/datum/antagonist/cultist/can_be_owned(mob/living/new_body)
	. = ..()
	if(.)
		. = is_convertable_to_cult(new_body)

/datum/antagonist/cultist/on_gain()
	if(SSticker && SSticker.mode && owner.mind)
		SSticker.mode.cult += owner.mind
		SSticker.mode.update_cult_icons_added(owner.mind)
		if(istype(SSticker.mode, /datum/game_mode/cult))
			var/datum/game_mode/cult/C = SSticker.mode
			C.memorize_cult_objectives(owner.mind)
		if(jobban_isbanned(owner, ROLE_CULTIST))
			INVOKE_ASYNC(SSticker.mode, /datum/game_mode.proc/replace_jobbaned_player, owner, ROLE_CULTIST, ROLE_CULTIST)
	if(owner.mind)
		owner.mind.special_role = "Cultist"
	owner.log_message("<font color=#960000>Has been converted to the cult of Nar'Sie!</font>", INDIVIDUAL_ATTACK_LOG)
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
		if(SSticker && SSticker.mode)
			SSticker.mode.cult -= owner.mind
			SSticker.mode.update_cult_icons_removed(owner.mind)
	to_chat(owner, "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Dark One and all your memories as its servant.</span>")
	owner.log_message("<font color=#960000>Has renounced the cult of Nar'Sie!</font>", INDIVIDUAL_ATTACK_LOG)
	if(!silent_update)
		owner.visible_message("<span class='big'>[owner] looks like [owner.p_they()] just reverted to their old faith!</span>")
	..()
