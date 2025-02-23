/obj/item/forensics_spoofer
	name = /obj/item/detective_scanner::name
	desc = "Used to adjacently scan objects and biomass for fibers and fingerprints. Can replicate the findings."
	icon = /obj/item/detective_scanner::icon
	icon_state = /obj/item/detective_scanner::icon_state
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = /obj/item/detective_scanner::inhand_icon_state
	worn_icon_state = /obj/item/detective_scanner::worn_icon_state
	lefthand_file = /obj/item/detective_scanner::lefthand_file
	righthand_file = /obj/item/detective_scanner::righthand_file
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	/// stored fibers in memory
	var/list/fibers = list()
	/// stored fingerprints in memory
	var/list/fingerprints = list()
	/// chosen fiber to add to target
	var/chosen_fiber
	/// chosen fingerprint to add to target
	var/chosen_fingerprint
	/// max storage for fibers/fingerprints seperate for each
	var/max_storage = 5
	/// do we scan for new material? if false will tamper
	var/scan_mode = TRUE
	/// do we make forensics scanner messages and sounds
	var/silent_mode = FALSE
	/// tamper cooldown time so people dont spam it on every single wall and thing ever
	var/tamper_cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(tamper_cooldown)

/obj/item/forensics_spoofer/Initialize(mapload)
	. = ..()
	// most things have add_fingerprint in their item interaction because lol lmao
	// tl;dr cut off the chain before anything fires so we dont add user fingerprints to target
	RegisterSignal(src, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(do_interact))

/obj/item/forensics_spoofer/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return
	scan_mode = !scan_mode
	balloon_alert(user, "now [scan_mode ? "scanning" : "applying"]")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// ok due to shenanigans basically every item interact adds your fingerprints to it which isnt ideal so we have this
/obj/item/forensics_spoofer/proc/do_interact(datum/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER
	if(scan_mode)
		INVOKE_ASYNC(src, PROC_REF(scan), interacting_with, user)
	else
		tamper(interacting_with, user, do_fibers = !isnull(chosen_fiber))
	return ITEM_INTERACT_SUCCESS

/obj/item/forensics_spoofer/proc/do_fake_scan(atom/target, mob/user)
	if(silent_mode)
		return
	playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
	user.visible_message(
		span_notice("\The [user] points \the [src] at \the [target] and performs a forensic scan.")
	)

/obj/item/forensics_spoofer/proc/clear_values(list/the_list)
	for(var/key in the_list)
		the_list[key] = ""

/obj/item/forensics_spoofer/proc/scan(atom/target, mob/living/user)
	do_fake_scan(target, user)
	if(isnull(target.forensics))
		target.balloon_alert(user, "nothing!")
		return ITEM_INTERACT_FAILURE
	var/list/new_fibers = LAZYCOPY(target.forensics.fibers) - fibers
	var/list/new_prints = LAZYCOPY(target.forensics.fingerprints) - fingerprints
	var/new_len = length(new_fibers) + length(new_prints)
	balloon_alert(user, "[new_len ? new_len : "no"] new prints/fibers")
	if(new_len)
		var/list/message = list(span_bold("Scan results (Unstored Only):"))
		for(var/text in new_fibers)
			message += span_notice("Fiber: [text]")
		if(length(fibers) > max_storage)
			message += span_boldwarning("Fiber storage full.")
		for(var/text in new_prints)
			message += span_notice("Fingerprint: [text]")
		if(length(fingerprints) > max_storage)
			message += span_boldwarning("Fingerprint storage full.")
		to_chat(user, boxed_message(jointext(message, "\n")), type = MESSAGE_TYPE_INFO)
	if(length(fingerprints) < max_storage)
		while(length(fingerprints) + length(new_prints) > max_storage)
			var/to_remove = tgui_input_list(user, "Too many prints, cancel to discard all", "What to discard", new_fibers)
			if(isnull(to_remove))
				return ITEM_INTERACT_FAILURE
			new_prints -= to_remove
		clear_values(new_prints)
		fingerprints += new_prints
		for(var/fingerprint in fingerprints)
			fingerprints[fingerprint] = get_name_from_fingerprint(fingerprint)
	if(length(fibers) < max_storage)
		while(length(fibers) + length(new_fibers) > max_storage)
			var/to_remove = tgui_input_list(user, "Too many prints, cancel to discard all", "What to discard", new_fibers)
			if(isnull(to_remove))
				return ITEM_INTERACT_FAILURE
			new_fibers -= to_remove
		clear_values(new_fibers)
		fibers += new_fibers
	return ITEM_INTERACT_SUCCESS

/obj/item/forensics_spoofer/proc/tamper(atom/target, mob/living/user, do_fibers = FALSE)
	do_fake_scan(target, user)
	if((!do_fibers && isnull(chosen_fingerprint)) || (do_fibers && isnull(chosen_fiber)))
		balloon_alert(user, "no [do_fibers ? "fiber" : "fingerprint"] selected!") // we CAN automatically select it but if they dont have it selected then they likely didnt know of it in the first place so they learn it now
		return ITEM_INTERACT_FAILURE
	if(!COOLDOWN_FINISHED(src, tamper_cooldown))
		balloon_alert(user, "please wait!")
		return ITEM_INTERACT_FAILURE
	if(!isnull(target.forensics) && LAZYFIND(do_fibers ? target.forensics.fibers : target.forensics.fingerprints, do_fibers ? chosen_fiber : chosen_fingerprint))
		balloon_alert(user, "already present!")
		return ITEM_INTERACT_FAILURE

	if(do_fibers)
		target.add_fiber_list(list(chosen_fiber))
		user.log_message("has tampered with the fingerprints/fibers of [src]. Added [chosen_fiber]", LOG_ATTACK)
	else
		target.add_fingerprint_list(list(chosen_fingerprint))
		user.log_message("has tampered with the fingerprints/fibers of [src]. Added [chosen_fingerprint]", LOG_ATTACK)

	target.balloon_alert(user, "[do_fibers ? "fiber" : "fingerprint"] added")
	target.add_hiddenprint(user)
	COOLDOWN_START(src, tamper_cooldown, tamper_cooldown_time)

	return ITEM_INTERACT_SUCCESS

/obj/item/forensics_spoofer/proc/get_name_from_fingerprint(fingerprint)
	. = "Unknown"
	for(var/datum/record/crew/player_record as anything in GLOB.manifest.general)
		if(player_record.fingerprint != fingerprint)
			continue
		return player_record.name

/obj/item/forensics_spoofer/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/forensics_spoofer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ForensicsSpoofer", name)
		ui.open()

/obj/item/forensics_spoofer/ui_static_data(mob/user)
	. = list(
		"max_storage" = max_storage,
	)

/obj/item/forensics_spoofer/ui_data(mob/user)
	return list(
		"scanmode" = scan_mode,
		"silent" = silent_mode,
		"fibers" = fibers,
		"fingerprints" = fingerprints,
		"chosen_fiber" = chosen_fiber,
		"chosen_fingerprint" = chosen_fingerprint,
	)

/obj/item/forensics_spoofer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!isnull(params["chosen"])) //fiber/print actions
		var/chosen = params["chosen"]
		switch(action)
			if("delete")
				if(chosen in fibers)
					if(chosen_fiber == chosen)
						chosen_fiber = null
					fibers -= chosen
				else
					if(chosen_fingerprint == chosen)
						chosen_fingerprint = null
					fingerprints -= chosen
				return TRUE
			if("choose")
				var/is_fiber = !!(chosen in fibers)
				chosen_fiber = is_fiber ? chosen : null
				chosen_fingerprint = is_fiber ? null : chosen
				return TRUE
			if("make_note")
				if(chosen in fibers)
					fibers[chosen] = params["note"]
				else
					fingerprints[chosen] = params["note"]
				return TRUE
	else
		switch(action)
			if("scanmode")
				scan_mode = !scan_mode
				return TRUE
			if("stealth")
				silent_mode = !silent_mode
				return TRUE
