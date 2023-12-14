/datum/status_effect/creep //allows darkspawn to move through lights without lightburn damage //Massmeta edit start
	id = "creep"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/creep
	var/datum/antagonist/darkspawn/darkspawn

/datum/status_effect/creep/get_examine_text()
	return span_warning("[owner.p_they(TRUE)] is surrounded by velvety, gently-waving black shadows!")

/datum/status_effect/creep/on_creation(mob/living/owner, datum/antagonist/darkspawn)
	. = ..()
	if(!.)
		return
	src.darkspawn = darkspawn

//tick instead of process
/datum/status_effect/creep/tick(seconds_between_ticks)
	if(!darkspawn)
		qdel(src)
		return
	if(!darkspawn.has_psi(1)) //ticks 5 times per second, 5 Psi lost per second
		to_chat(owner, "<span class='warning'>Without the Psi to maintain it, your protective aura vanishes!</span>")
		qdel(src)
		return
	darkspawn.use_psi(1)

/atom/movable/screen/alert/status_effect/creep
	name = "Creep"
	desc = "You are immune to lightburn. Drains 1 Psi per second."
	icon = 'massmeta/icons/mob/actions/actions_darkspawn.dmi'
	icon_state = "creep"

/datum/status_effect/shadow_dance //allows darkspawn to move through lights without lightburn damage //Massmeta edit start
	id = "shadowdance"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/shadow_dance
	var/datum/antagonist/darkspawn/darkspawn

/datum/status_effect/shadow_dance/on_creation(mob/living/owner, datum/antagonist/darkspawn)
	. = ..()
	if(!.)
		return
	src.darkspawn = darkspawn

/datum/status_effect/shadow_dance/tick()
	if(!darkspawn)
		qdel(src)
		return
	if(!darkspawn.has_psi(5))
		to_chat(owner, "<span class='warning'>You dont have enough psi to mantain the dance!</span>")
		qdel(src)
		return
	darkspawn.use_psi(5)

/atom/movable/screen/alert/status_effect/shadow_dance
	name = "Shadow Dance"
	desc = "You are able to avoid projectiles while in darkness."
	icon = 'icons/mob/actions/actions_minor_antag.dmi'
	icon_state = "ninja_cloak"

/datum/status_effect/time_dilation //used by darkspawn; greatly increases action times etc
	id = "time_dilation"
	duration = 600
	alert_type = /atom/movable/screen/alert/status_effect/time_dilation

/datum/status_effect/time_dilation/get_examine_text()
	return span_warning("[owner.p_they(TRUE)] is moving jerkily and unpredictably!")

/datum/status_effect/time_dilation/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/time_dilation)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/time_dilation)
	return TRUE

/datum/status_effect/time_dilation/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/time_dilation)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/time_dilation)

/atom/movable/screen/alert/status_effect/time_dilation
	name = "Time Dilation"
	desc = "Your actions are twice as fast, and the delay between them is halved."
	icon = 'massmeta/icons/mob/actions/actions_darkspawn.dmi'
	icon_state = "time_dilation" //Massmeta edit end
