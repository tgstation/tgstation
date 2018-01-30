//Allows you to move through light unimpeded while active. Drains 5 Psi per second.
/datum/action/innate/darkspawn/creep
	name = "Creep"
	id = "creep"
	desc = "Grants immunity to lightburn while active. Can be toggled on and off. Drains 5 Psi per second."
	button_icon_state = "creep"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 5
	psi_addendum = " to activate and per second"
	lucidity_price = 2

/datum/action/innate/darkspawn/creep/process()
	var/mob/living/L = owner
	active = L.has_status_effect(STATUS_EFFECT_CREEP)

/datum/action/innate/darkspawn/creep/Activate()
	var/mob/living/L = owner
	owner.visible_message("<span class='warning'>Velvety shadows coalesce around [owner]!</span>", "<span class='velvet'><b>odeahz</b><br>You begin using Psi to shield yourself from lightburn.</span>")
	playsound(owner, 'sound/magic/devour_will_victim.ogg', 50, TRUE)
	L.apply_status_effect(STATUS_EFFECT_CREEP, darkspawn)

/datum/action/innate/darkspawn/creep/Deactivate()
	var/mob/living/L = owner
	to_chat(owner, "<span class='velvet'>You release your grip on the shadows.</span>")
	playsound(owner, 'sound/magic/devour_will_end.ogg', 50, TRUE)
	L.remove_status_effect(STATUS_EFFECT_CREEP)
