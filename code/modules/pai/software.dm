#define CABLE_LENGTH 2

/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["door_jack"] = hacking_cable
	data["image"] = card.emotion_icon
	data["installed"] = installed_software
	data["ram"] = ram
	return data

/mob/living/silicon/pai/ui_static_data(mob/user)
	var/list/data = list()
	data["available"] = available_software
	data["directives"] = laws.supplied
	data["emagged"] = emagged
	data["languages"] = languages_granted
	data["master_name"] = master_name
	data["master_dna"] = master_dna
	data["medical_records"] = medical_records
	data["security_records"] = security_records
	return data

/mob/living/silicon/pai/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(available_software[action] && !installed_software.Find(action))
		to_chat(usr, span_warning("You do not have this software installed."))
		CRASH("[usr] attempted to activate software they hadn't installed: [action]")
	switch(action)
		if("Atmospheric Sensor")
			atmos_analyzer.attack_self(src)
			return TRUE
		if("buy")
			buy_software(usr, params["selection"])
			return TRUE
		if("change image")
			change_image(usr)
			return TRUE
		if("check dna")
			check_dna(usr)
			return TRUE
		if("Crew Manifest")
			ai_roster()
			return TRUE
		if("Digital Messenger")
			modularInterface?.interact(usr)
			return TRUE
		if("Door Jack")
			door_jack(usr, params["mode"])
			return TRUE
		if("Encryption Slot")
			to_chat(usr, span_notice("You have [!encrypt_mod ? "enabled" : "disabled"] encrypted radio frequencies."))
			encrypt_mod = !encrypt_mod
			radio.subspace_transmission = !radio.subspace_transmission
			return TRUE
		if("Host Scan")
			host_scan(usr, params["mode"])
			return TRUE
		if("Internal GPS")
			internal_gps.attack_self(src)
			return TRUE
		if("Music Synthesizer")
			instrument.interact(src) // Open Instrument
			return TRUE
		if("Medical HUD")
			toggle_hud(usr, "medical")
			return TRUE
		if("Newscaster")
			newscaster.ui_interact(src)
			return TRUE
		if("Photography Module")
			use_camera(usr, params["mode"])
			return TRUE
		if("refresh")
			if(params["list"] == "security" && !installed_software.Find("security records") || params["list"] == "medical" && !installed_software.Find("medical records"))
				return FALSE
			refresh_records(ui, params["list"])
			return TRUE
		if("Remote Signaler")
			signaler.ui_interact(src)
			return TRUE
		if("Security HUD")
			toggle_hud(usr, "security")
			return TRUE
		if("Universal Translator")
			grant_languages(usr, ui)
			return TRUE
	return FALSE

/**
 * Purchases the selected software from the list and deducts their
 * available ram.
 *
 * @param {mob} user The user purchasing the software.
 * @param {string} selection The software to purchase.
 * @return {bool} TRUE if the software was purchased, CRASH otherwise.
 */
/mob/living/silicon/pai/proc/buy_software(mob/user, selection)
	if(!available_software.Find(selection) || installed_software.Find(selection))
		to_chat(user, span_warning("Error: Software unavailable."))
		CRASH("[user] tried to purchase unavailable software as a pAI.")
	var/cost = available_software[selection]
	if(ram < cost)
		to_chat(user, span_warning("Error: Insufficient RAM available."))
		CRASH("[user] tried to purchase software with insufficient RAM.")
	installed_software.Add(selection)
	ram -= cost
	var/datum/hud/pai/pAIhud = hud_used
	pAIhud?.update_software_buttons()
	switch(selection)
		if("Atmospheric Sensor")
			atmos_analyzer = new(src)
		if("Digital Messenger")
			create_modularInterface()
		if("Host Scan")
			host_scan = new(src)
		if("Internal GPS")
			internal_gps = new(src)
		if("Music Synthesizer")
			instrument = new(src)
		if("Newscaster")
			newscaster = new(src)
		if("Photography Module")
			aicamera = new(src)
			aicamera.flash_enabled = TRUE
		if("Remote Signaler")
			signaler = new(src)
	return TRUE

/**
 * Changes the image displayed on the pAI.
 *
 * @param {mob} user The user who is changing the image.
 * @return {bool} TRUE if the image was changed, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/change_image(mob/user)
	var/new_image = tgui_input_list(user, "Select your new display image", "Display Image", possible_overlays)
	if(isnull(new_image))
		return FALSE
	card.emotion_icon = new_image
	card.update_appearance()
	return TRUE

/**
 * Supporting proc for the pAI to prick it's master's hand
 * or... whatever. It must be held in order to work
 * Gives the owner a popup if they want to get the jab.
 *
 * @param {mob} user The pAI requesting the sample.
 * @param {living/carbon} master The holder of the pAI.
 * @return {boolean} TRUE if a sample was taken, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/check_dna(mob/user)
	var/mob/living/carbon/holder = get_holder()
	if(!holder)
		to_chat(user, span_warning("You must be in someone's hands to do this!"))
		return FALSE
	to_chat(user, span_notice("Requesting a DNA sample."))
	if(tgui_alert(holder, "[user] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "Checking DNA", list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("[holder] does not seem like [holder.p_theyre()]	going to provide a DNA sample willingly."))
		return FALSE
	holder.visible_message(span_notice("[holder] presses [holder.p_their()]	thumb against [user]."), span_notice("You press your thumb against [user]."), span_notice("[user] makes a sharp clicking sound as it extracts DNA material from [holder]."))
	if(!holder.has_dna())
		to_chat(user, span_warning("No DNA detected."))
		return FALSE
	to_chat(user, span_boldannounce(("[holder]'s UE string: [holder.dna.unique_enzymes]")))
	to_chat(user, span_notice("DNA [holder.dna.unique_enzymes == master_dna ? "matches" : "does not match"] our stored Master's DNA."))
	return TRUE

/**
 * Switch that handles door jack operations.
 *
 * @param {mob} user The user operating the door jack.
 * @param {string} mode The requested operation of the door jack.
 * @return {bool} TRUE if the door jack state was switched, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/door_jack(mob/user, mode)
	switch(mode)
		if("cable")
			extend_cable(user)
			return TRUE
		if("cancel")
			QDEL_NULL(hacking_cable)
			visible_message(span_notice("The cable retracts into the pAI."))
			return TRUE
		if("jack")
			hack_door(user)
			return TRUE
	return FALSE

/**
 * Extend cable supporting proc
 *
 * When doorjack is installed, allows the pAI to drop
 * a cable which is placed either on the floor or in
 * someone's hands based (on distance).
 *
 * @param {mob} user The pAI dropping the cable
 * @return {bool} TRUE if the cable was dropped, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/extend_cable(mob/user)
	QDEL_NULL(hacking_cable) //clear any old cables
	hacking_cable = new
	var/mob/living/carbon/hacker = get_holder()
	if(hacker && hacker.put_in_hands(hacking_cable))
		hacker.visible_message(span_warning("A port on [user] opens to reveal \a [hacking_cable], which you quickly grab hold of."), span_hear("You hear the soft click of a plastic	component and manage to catch the falling [hacking_cable]."))
		track(hacking_cable)
		return TRUE
	hacking_cable.forceMove(drop_location())
	hacking_cable.visible_message(span_warning("A port on [user] opens to reveal \a [hacking_cable], which promptly falls to the floor."), span_hear("You hear the soft click of a plastic component fall to the ground."))
	track(hacking_cable)
	return TRUE

/**
 * Grant all languages to the current pAI.
 *
 * @param {mob} user The pAI receiving the languages.
 * @param {tgui} ui The interface for the pAI.
 * @return {bool} TRUE if the languages were granted, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/grant_languages(mob/user, datum/tgui/ui)
	if(languages_granted)
		to_chat(usr, span_warning("Error: You know all that there is to know!"))
		return FALSE
	grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_SOFTWARE)
	languages_granted = TRUE
	ui.send_full_update()
	return TRUE

/**
 * Door jacking supporting proc
 * After a 10 second timer, the door will crack open,
 * provided they don't move out of the way.
 *
 * @param {mob} user The pAI attempting to hack the door.
 * @return {bool} TRUE if the door was jacked, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/hack_door(mob/user)
	if(!hacking_cable)
		CRASH("[user] attempted to hack a door without a cable.")
	if(!hacking_cable?.machine)
		to_chat(user, span_warning("You must be connected to a machine to do this."))
		return FALSE
	playsound(user, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
	balloon_alert(user, "overriding...")
	// Now begin hacking
	if(!do_after(src, 15 SECONDS, hacking_cable.machine, timed_action_flags = NONE,	progress = TRUE))
		balloon_alert(user, "failed! retracting...")
		hacking_cable.visible_message(
			span_warning("[hacking_cable] rapidly retracts back into its spool."), span_hear("You hear a click and the sound of wire spooling rapidly."))
		QDEL_NULL(hacking_cable)
		if(!QDELETED(card))
			card.update_appearance()
		return FALSE
	var/obj/machinery/door/door = hacking_cable.machine
	balloon_alert(user, "success!")
	door.open()
	QDEL_NULL(hacking_cable)
	return TRUE

/**
 * A periodic check to see if the source pAI is nearby.
 * Deletes the extended cable if the source pAI is not nearby.
 */
/mob/living/silicon/pai/proc/handle_move(atom/movable/source, atom/old_loc,	dir, forced, list/old_locs)
	if(ismovable(old_loc))
		untrack(old_loc)
	if(!IN_GIVEN_RANGE(src, hacking_cable, CABLE_LENGTH))
		QDEL_NULL(hacking_cable)
		visible_message(span_notice("The cable retracts into the pAI."))
		return TRUE
	if(ismovable(source.loc))
		track(source.loc)

/**
 * Host scan supporting proc
 *
 * Allows the pAI to scan its host's health vitals
 * An integrated health analyzer.
 *
 * @param {mob} user The pAI requesting the scan.
 * @return {boolean} TRUE if the scan was successful, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/host_scan(mob/user, mode)
	if(mode == "master")
		if(!master_ref)
			to_chat(user, span_warning("You are not bound to a master!"))
			return FALSE
		var/resolved_master = find_master(user)
		if(!resolved_master)
			return FALSE
		to_chat(user, span_notice("Your master, [master_name], is reporting the current vitals:"))
		host_scan.attack(resolved_master, user)
		return TRUE
	if(mode == "target")
		var/mob/living/target = get_holder()
		if(!target || !isliving(target))
			to_chat(user, span_warning("You are not being carried by anyone!"))
			return FALSE
		host_scan.attack(target, user)
		return TRUE
	return FALSE

/**
 * Refreshes records on screen of the pAI.
 *
 * @param {tgui} ui The interface for the pAI.
 * @param {string} list The list of records to refresh.
 */
/mob/living/silicon/pai/proc/refresh_records(datum/tgui/ui, list)
	if(list == "medical")
		medical_records = GLOB.data_core.get_general_records()
	if(list == "security")
		security_records = GLOB.data_core.get_security_records()
	ui.send_full_update()
	return TRUE

/**
 * Proc that toggles any active huds based on the option.
 *
 * @param {mob} user The pAI toggling the hud.
 * @param {string} option The hud to toggle.
 */
/mob/living/silicon/pai/proc/toggle_hud(mob/user, option)
	if(!option)
		return FALSE
	var/datum/atom_hud/hud
	var/hud_on
	if(option == "medical")
		hud = GLOB.huds[med_hud]
		medHUD = !medHUD
		hud_on = medHUD
	if(option == "security")
		hud = GLOB.huds[sec_hud]
		secHUD = !secHUD
		hud_on = secHUD
	if(hud_on)
		hud.show_to(user)
	else
		hud.hide_from(user)
	return TRUE

/** Tracks the associated hacking_cable */
/mob/living/silicon/pai/proc/track(atom/movable/thing)
	RegisterSignal(thing, COMSIG_MOVABLE_MOVED, .proc/handle_move)
	var/list/locations = get_nested_locs(thing, include_turf = FALSE)
	for(var/atom/movable/location in locations)
		RegisterSignal(location, COMSIG_MOVABLE_MOVED, .proc/handle_move)

/** Untracks the associated hacking_cable */
/mob/living/silicon/pai/proc/untrack(atom/movable/thing)
	UnregisterSignal(thing, COMSIG_MOVABLE_MOVED)
	var/list/locations = get_nested_locs(thing, include_turf = FALSE)
	for(var/atom/movable/location in locations)
		UnregisterSignal(location, COMSIG_MOVABLE_MOVED)

/**
 * All inclusive camera proc. Zooms, snaps, prints.
 *
 * @param {mob} user The pAI requesting the camera.
 * @param {string} mode The camera option to toggle.
 * @return {boolean} TRUE if the camera worked.
 */
/mob/living/silicon/pai/proc/use_camera(mob/user, mode)
	if(!aicamera)
		CRASH("[user] tried to use the camera, but it was null.")
	switch(mode)
		if("camera")
			aicamera.toggle_camera_mode(user)
		if("printer")
			aicamera.paiprint(user)
		if("zoom")
			aicamera.adjust_zoom(user)
	return TRUE

#undef CABLE_LENGTH
