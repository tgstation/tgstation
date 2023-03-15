//After a brief charge-up, equips a temporary dark bead that can be used on a human to knock them out and drain their will, making them vulnerable to conversion.
/datum/action/innate/darkspawn/devour_will
	name = "Devour Will"
	id = "devour_will"
	desc = "Creates a dark bead that can be used on a human to fully recharge Psi, gain one lucidity, and knock them unconscious. The victim will be stunned for the duration of the channel, being interrupted \
	will knock both you and the victim down. Costs 5 Psi."
	button_icon_state = "devour_will"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_INCAPACITATED | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	psi_cost = 5
	blacklisted = TRUE
	var/list/victims //A list of people we've used the bead on recently; we can't drain them again so soon
	var/last_victim

/datum/action/innate/darkspawn/devour_will/New()
	..()
	victims = list()

/datum/action/innate/darkspawn/devour_will/IsAvailable(feedback = FALSE)
	if(!owner || istype(owner, /mob/living/simple_animal/hostile/crawling_shadows) ||istype(owner, /mob/living/simple_animal/hostile/darkspawn_progenitor) || !owner.get_empty_held_indexes())
		return
	return ..()

/datum/action/innate/darkspawn/devour_will/Activate()
	owner.visible_message(span_warning("A glowing black orb appears in [owner]'s hand!"), "<span class='velvet'><b>pwga...iejz</b><br>\
	You form a dark bead in your hand.</span>")
	playsound(owner, 'massmeta/sounds/magic/devour_will_form.ogg', 50, 1)
	var/obj/item/dark_bead/B = new
	owner.put_in_hands(B)
	B.linked_ability = src
	return TRUE

/datum/action/innate/darkspawn/devour_will/proc/make_eligible(mob/living/L)
	if(!L || !victims[L])
		return
	victims[L] = FALSE
	to_chat(owner, span_notice("[L] has recovered from their draining and is vulnerable to Devour Will again."))
	return TRUE
