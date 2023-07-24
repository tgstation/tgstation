/datum/action/cooldown/eminence/linked_abscond
	name = "Linked Abscond"
	desc = "Absconds a fellow servant and whomever they may be pulling back to reebe if they stand still for 7 seconds."
	button_icon_state = "Linked Abscond"
	cooldown_time = 4 MINUTES

/datum/action/cooldown/eminence/linked_abscond/Activate(atom/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/eminence/em_user = usr
	if(!em_user.marked_servant)
		to_chat(em_user, span_notice("You dont currently have a marked servant!"))
		return FALSE

	var/mob/living/teleported = em_user.marked_servant?.resolve()
	if(teleported.has_reagent(/datum/reagent/water/holywater)) //cant abscond servents with holy water in them, use reagent purge
		to_chat(em_user, span_warning("Holy water inside [teleported] is blocking you from absconding them, use reagent purge!"))
		return FALSE

	to_chat(em_user, span_brass("You begin to recall [teleported]."))
	to_chat(teleported, span_bigbrass("You are being recalled by the eminence."))
	teleported.visible_message(span_warning("[teleported] flares briefly."))

	if(!do_after(em_user, 7 SECONDS, teleported))
		to_chat(em_user, span_warning("You fail to recall [teleported]."))
		return FALSE
	teleported.visible_message(span_warning("[teleported] phases out of existence!"))
	try_servant_warp(teleported, get_turf(pick(GLOB.abscond_markers)))
	to_chat(em_user, "You recall [teleported].")
	em_user.marked_servant = null
	return TRUE
