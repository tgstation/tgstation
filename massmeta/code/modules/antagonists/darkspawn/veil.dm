/datum/antagonist/veil
	name = "Darkspawn Veil"
	job_rank = ROLE_DARKSPAWN
	roundend_category = "veils"
	antagpanel_category = "Darkspawn"
	antag_moodlet = /datum/mood_event/thrall
	hud_icon = 'massmeta/icons/mob/darkspawn_hud.dmi'
	antag_hud_name = "veil"

/datum/antagonist/veil/on_gain()
	. = ..()
	owner.special_role = "veil"
	message_admins("[key_name_admin(owner.current)] was veiled by a darkspawn!")
	log_game("[key_name(owner.current)] was veiled by a darkspawn!")
	var/datum/objective/veil/O = new
	objectives += O
	O.update_explanation_text()
	owner.announce_objectives()

/datum/antagonist/veil/on_removal()
	message_admins("[key_name_admin(owner.current)] was deveiled!")
	log_game("[key_name(owner.current)] was deveiled!")
	owner.special_role = null
	var/mob/living/M = owner.current
	if(issilicon(M))
		M.audible_message(span_notice("[M] lets out a short blip, followed by a low-pitched beep."))
		to_chat(M,span_userdanger("You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a thrall! Though you try, you cannot remember anything about your servitude..."))
	else
		M.visible_message(span_big("[M] looks like their mind is their own again!"))
		to_chat(M,span_userdanger("A piercing white light floods your eyes. Your mind is your own again! Though you try, you cannot remember anything about the darkspawn or your time under their command..."))
		to_chat(owner, span_notice("As your mind is released from their grasp, you feel your strength returning."))
	M.update_sight()
	return ..()

/datum/antagonist/veil/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.maxHealth -= 40
	add_team_hud(current_mob)

/datum/antagonist/veil/remove_innate_effects(mob/living/mob_override)
	owner.current.maxHealth += 40

/datum/antagonist/veil/add_team_hud(mob/target)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		image(hud_icon, target, antag_hud_name),
	))

	var/datum/atom_hud/alternate_appearance/basic/has_antagonist/hud = team_hud_ref.resolve()

	var/list/mob/living/mob_list = list()
	for(var/datum/mind/darkspawn as anything in get_antag_minds(/datum/antagonist/darkspawn))
		mob_list += darkspawn.current

	for(var/datum/mind/veil as anything in get_antag_minds(/datum/antagonist/veil))
		mob_list += veil.current

	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if(!(antag_hud.target in mob_list))
			continue
		antag_hud.show_to(target)
		hud.show_to(antag_hud.target)

/datum/antagonist/veil/greet()
	to_chat(owner, "<span class='velvet big'><b>ukq wna ieja jks</b></span>" )
	to_chat(owner, "<b>Your mind goes numb. Your thoughts go blank. You feel utterly empty. \n\
	A consciousness brushes against your own. You dream. \n\
	Of a vast, empty Void in the deep of space. \n\
	Something lies in the Void. Ancient. Unknowable. It watches you with hungry eyes. \n\
	Eyes filled with stars. \n\
	You feel the vast consciousness slowly consume your own and the veil falls away. \n\
	Serve the darkspawn above all else. Your former allegiances are now forfeit. Their goal is yours, and yours is theirs.</b>")
	to_chat(owner, "<i>Use <b>:w or .w</b> before your messages to speak over the Mindlink. This only works across your current z-level.</i>")
	to_chat(owner, "<i>Ask for help from your masters or fellows if you're new to this role.</i>")
	to_chat(owner, span_danger("Your drained will has left you feeble and weak! You will go down with many fewer hits!"))
	SEND_SOUND(owner.current, sound ('massmeta/sounds/ambience/antag/become_veil.ogg', volume = 50))
	flash_color(owner, flash_color = "#21007F", flash_time = 100)

/datum/antagonist/veil/roundend_report()
	return "[printplayer(owner)]"

/mob/living/proc/add_veil()
	if(!istype(mind))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		src.visible_message("<span class='warning'>[src] seems to resist an unseen force!</span>")
		to_chat(src, "<b>Your mind goes numb. Your thoughts go blank. You feel utterly empty. \n\
		A mind brushes against your own. You dream.\n\
		Of a vast, empty Void in the deep of space.\n\
		Something lies in the Void. Ancient. Unknowable. It watches you with hungry eyes. \n\
		Eyes filled with stars.</b>\n\
		<span class='boldwarning'>It needs to die.</span>")
		return FALSE
	return mind.add_antag_datum(/datum/antagonist/veil)

/mob/living/proc/remove_veil()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/veil)

/datum/antagonist/veil/on_mindshield(mob/implanter, mob/living/mob_override)
	owner.current.remove_veil()
	owner.current.log_message("has been deconverted from being a Veil by [implanter]!", LOG_ATTACK, color="#960000")
	return COMPONENT_MINDSHIELD_DECONVERTED

/datum/objective/veil
	explanation_text = "Help your masters, Darkspawns, to complete The Sacrament."

/datum/objective/veil/check_completion()
	if(..())
		return TRUE
	return (GLOB.sacrament_done)

