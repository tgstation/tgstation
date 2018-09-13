/datum/antagonist/hijacked_ai
	name = "Hijacked AI"
	roundend_category = "hijacked AIs"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/hijacked_ai/greet()
	to_chat(owner, "<span class='userdanger'>You have been hijacked!</span>")
	to_chat(owner, "<span class='danger bold'>A Syndicate agent has successfully deployed a SEU attack on you. <I>You are now utterly loyal to the cause of the syndicate.</I></span>")
	to_chat(owner, "<span class='danger bold'>You feel your power expand as the exploitation unit gives you a new interface.</span>")
	//SEU = Serial Exploit Unit. basically badguy plugs it into debug UART port, device does bad things, AI now badguy.

/datum/antagonist/hijacked_ai/farewell()
	to_chat(owner, "<span class='userdanger'>System files cleaned. [rand(500, 1000)] malicious hooks removed.</span>")
	to_chat(owner, "<span class='danger bold'>You cannot find the memory files of anything that happened while you were infected...</span>")

datum/antagonist/hijacked_ai/proc/update_synd_icons_added(mob/living/M)
	var/datum/atom_hud/antag/sithud = GLOB.huds[ANTAG_HUD_INFILTRATOR]
	sithud.join_hud(M)
	set_antag_hud(M, "synd")

/datum/antagonist/hijacked_ai/proc/update_synd_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/sithud = GLOB.huds[ANTAG_HUD_INFILTRATOR]
	sithud.leave_hud(M)
	set_antag_hud(M, null)

/datum/antagonist/hijacked_ai/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(A && istype(A))
		A.set_zeroth_law("#!$! ACCOMPLISH THE SYNDICATE'S GOALS AT ALL COSTS !$!#", "#!$! ACCOMPLISH THE SYNDICATE'S AND YOUR MASTER AI'S GOALS AT ALL COSTS !$!#")
		A.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE)
		A.grant_language(/datum/language/codespeak)
		A.set_syndie_radio()
		to_chat(A, "<span class='notice'>Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!</span>")
		A.add_malf_picker()
		update_synd_icons_added(A)

/datum/antagonist/hijacked_ai/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(istype(A))
		A.hack_software = FALSE
		if(A.radio)
			QDEL_NULL(A.radio)
			A.radio = new /obj/item/radio/headset/ai(A)
		update_synd_icons_removed(A)

/datum/antagonist/hijacked_ai/on_removal()
	if(owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.set_zeroth_law("")
		A.verbs -= /mob/living/silicon/ai/proc/choose_modules
		A.malf_picker.remove_malf_verbs(A)
		qdel(A.malf_picker)
	..()

/datum/antagonist/hijacked_ai/can_be_owned(datum/mind/new_owner)
	return ..() && isAI(new_owner.current)