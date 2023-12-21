/datum/quirk/cyborg_lover
	name = "Cyborg Lover"
	desc = "You find silicon life forms fascinating! You like inspecting and touching their hulls and robo-bodies, as well you like being touched by their manipulators."
	icon = FA_ICON_ROBOT
	value = 2
	gain_text = span_notice("You are fascinated by silicon life forms.")
	lose_text = span_danger("Cyborgs and other silicons aren't cool anymore.")
	medical_record_text = "Patient reports being fascinated by silicon life forms."
	mail_goodies = list(
		/obj/item/stock_parts/cell/potato,
		/obj/item/stack/cable_coil,
		/obj/item/toy/talking/ai,
		/obj/item/toy/figure/borg,
	)

/datum/quirk/cyborg_lover/add(client/client_source)
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	fan.show_to(quirk_holder)

/datum/quirk/cyborg_lover/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source)
	. = ..()
	RegisterSignal(new_holder, COMSIG_MOB_PAT_BORG, PROC_REF(pat_cyborg), override = TRUE)
	RegisterSignal(new_holder, COMSIG_BORG_TOUCH_MOB, PROC_REF(touched_by_cyborg), override = TRUE)
	RegisterSignal(new_holder, COMSIG_BORG_HUG_MOB, PROC_REF(hugged_by_cyborg), override = TRUE)

/datum/quirk/cyborg_lover/remove_from_current_holder(quirk_transfer)
	UnregisterSignal(quirk_holder, list(COMSIG_MOB_PAT_BORG, COMSIG_BORG_TOUCH_MOB, COMSIG_BORG_HUG_MOB))
	return ..()

/datum/quirk/cyborg_lover/proc/pat_cyborg()
	SIGNAL_HANDLER
	quirk_holder.add_mood_event("pat_borg", /datum/mood_event/pat_borg)

/datum/quirk/cyborg_lover/proc/touched_by_cyborg()
	SIGNAL_HANDLER
	quirk_holder.add_mood_event("borg_touch", /datum/mood_event/borg_touch)

/datum/quirk/cyborg_lover/proc/hugged_by_cyborg(borghugitem, mob/living/silicon/robot/hugger)
	SIGNAL_HANDLER
	hugger.visible_message(
		span_notice("[hugger] hugs [quirk_holder] in a firm bear-hug! [quirk_holder] looks satisfied!"),
		span_notice("You hug [quirk_holder] firmly to make [quirk_holder.p_them()] feel better! [quirk_holder] looks satisfied!"),
	)
	quirk_holder.add_mood_event("borg_hug", /datum/mood_event/borg_hug)
	return COMSIG_BORG_HUG_HANDLED
