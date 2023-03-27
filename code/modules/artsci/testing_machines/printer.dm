/datum/export/analyzed_artifact
	cost = -CARGO_CRATE_VALUE
	k_elasticity = 0
	unit_name = "artifact"
	allow_negative_cost = TRUE

/datum/export/analyzed_artifact/applies_to(obj/O, apply_elastic = TRUE)
	if(O.GetComponent(/datum/component/artifact))
		return TRUE
	return ..()

/datum/export/analyzed_artifact/get_cost(obj/O)
	var/obj/item/sticker/analysis_form/M = O
	return 3595354

/obj/item/sticker/analysis_form
	name = "analysis form"
	desc = "An analysis form for artifacts, has adhesive on the back."
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "analysisform"
	inhand_icon_state = "paper"
	throwforce = 0
	throw_range = 1
	throw_speed = 1
	max_integrity = 50
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	contraband = FALSE
	stick_type = /datum/component/attached_sticker/analysis_form
	var/chosen_origin = ""
	var/list/chosentriggers = list()
	var/chosentype = ""

/obj/item/sticker/analysis_form/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/pen))
		ui_interact(user)
	else
		return ..()

/obj/item/sticker/analysis_form/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtifactForm", name)
		ui.open()

/obj/item/sticker/analysis_form/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!istype(usr.get_active_held_item(), /obj/item/pen))
		to_chat(usr, span_notice("You need a pen to write on [src]!"))
		return
	//SEND_SIGNAL(attached, COMSIG_ANALYSISFORM_CHANGED, src)
	switch(action)
		if("origin")
			chosen_origin = params["origin"]
			return
		if("type")
			chosentype = params["type"]
			return
		if("trigger")
			var/trig = params["trigger"]
			if(trig in chosentriggers)
				chosentriggers -= trig
			else
				chosentriggers += trig
			return

/obj/item/sticker/analysis_form/ui_static_data(mob/user)
	. = ..()
	.["allorigins"] = SSartifacts.artifact_origin_name_to_typename
	.["alltypes"] = SSartifacts.artifact_type_names
	.["alltriggers"] = SSartifacts.artifact_trigger_name_to_type
	return

/obj/item/sticker/analysis_form/ui_data(mob/user)
	. = ..()
	.["chosenorigin"] = chosen_origin
	.["chosentype"] = chosentype
	.["chosentriggers"] = chosentriggers
	return .

/obj/item/sticker/analysis_form/can_interact(mob/user)
	if(!loc)
		return TRUE
	return ..()

/obj/item/sticker/analysis_form/examine(mob/user)
	. = ..()
	//if(!in_range(user, (attached ? attached : src)) && !isobserver(user))
	//	return
	ui_interact(user)

/obj/item/sticker/analysis_form/ui_status(mob/user,/datum/ui_state/ui_state)
	//if(!in_range(user, (attached ? attached : src)) && !isobserver(user))
		//return UI_CLOSE
	if(user.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB) || (isobserver(user) && !isAdminGhostAI(user)))
		return UI_UPDATE
	if(user.is_blind())
		to_chat(user, span_warning("You are blind!"))
		return UI_CLOSE
	if(!user.can_read(src))
		return UI_CLOSE
	if(!loc)
		return UI_INTERACTIVE
	return ..()