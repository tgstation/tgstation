//Allows you to move through light unimpeded while active. Drains 5 Psi per second.
/datum/action/innate/darkspawn/shadow_dance
	name = "Shadow Dance"
	id = "shadowdance"
	desc = "Allows you to avoid projectiles while in darkness. Can be toggled on and off. Drains 5 Psi per second."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS
	psi_cost = 10
	psi_addendum = " to activate and 5 per second"
	lucidity_price = 2

/datum/action/innate/darkspawn/shadow_dance/IsAvailable(feedback = FALSE)
	if(istype(owner, /mob/living/simple_animal/hostile/crawling_shadows))
		return
	return ..()

/datum/action/innate/darkspawn/shadow_dance/process()
	var/mob/living/L = owner
	active = L.has_status_effect(/datum/status_effect/shadow_dance)

/datum/action/innate/darkspawn/shadow_dance/Activate()
	var/mob/living/L = owner
	playsound(owner, 'massmeta/sounds/magic/devour_will_victim.ogg', 50, TRUE)
	L.apply_status_effect(/datum/status_effect/shadow_dance, darkspawn)

/datum/action/innate/darkspawn/shadow_dance/Deactivate()
	var/mob/living/L = owner
	playsound(owner, 'massmeta/sounds/magic/devour_will_end.ogg', 50, TRUE)
	L.remove_status_effect(/datum/status_effect/shadow_dance)
