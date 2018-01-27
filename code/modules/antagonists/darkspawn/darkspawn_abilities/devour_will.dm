//After a brief charge-up, equips a temporary dark bead that can be used on a human to knock them out and drain their will, making them vulnerable to conversion.
/datum/action/innate/darkspawn/devour_will
	name = "Devour Will"
	id = "devour_will"
	desc = "Creates a dark bead that can be used on a human to fully recharge Psi, gain one lucidity, and knock them unconscious. Costs 5 Psi."
	button_icon_state = "devour_will"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	psi_cost = 5
	blacklisted = TRUE
	var/list/victims //A list of people we've used the bead on recently; we can't drain them again so soon

/datum/action/innate/darkspawn/devour_will/New()
	..()
	victims = list()

/datum/action/innate/darkspawn/devour_will/IsAvailable()
	if(!owner || !owner.get_empty_held_indexes())
		return
	return ..()

/datum/action/innate/darkspawn/devour_will/Activate()
	in_use = TRUE
	owner.visible_message("<span class='warning'>[owner]'s hand begins to shimmer...</span>", "<span class='velvet'><b>pwga...</b><br>\
	You begin forming a dark bead...</span>")
	playsound(owner, 'sound/magic/devour_will_begin.ogg', 50, 1)
	if(!do_after(owner, 10, target = owner))
		in_use = FALSE
		return
	in_use = FALSE
	owner.visible_message("<span class='warning'>A glowing black orb appears in [owner]'s hand!</span>", "<span class='velvet'><b>...iejz</b><br>\
	You form a dark bead in your hand.</span>")
	playsound(owner, 'sound/magic/devour_will_form.ogg', 50, 1)
	var/obj/item/dark_bead/B = new
	owner.put_in_hands(B)
	B.linked_ability = src
	return TRUE

/datum/action/innate/darkspawn/devour_will/proc/make_eligible(mob/living/L)
	if(!L || !victims[L])
		return
	victims[L] = null
	to_chat(owner, "<span class='notice'>[L] has recovered from their draining and is vulnerable to Devour Will again.</span>")
	return TRUE
