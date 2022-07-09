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
	data["master_name"] = master
	data["master_dna"] = master_dna
	data["medical_records"] = medical_records
	data["security_records"] = security_records
	return data

/mob/living/silicon/pai/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("atmosphere_sensor")
			check_if_installed("atmosphere sensor")
			if(!atmos_analyzer)
				atmos_analyzer = new(src)
			atmos_analyzer.attack_self(src)
			return TRUE
		if("buy")
			buy_software(usr, params["selection"])
			return TRUE
		if("camera_zoom")
			check_if_installed("camera zoom")
			if(aicamera)
				aicamera.adjust_zoom(usr)
				return TRUE
			return FALSE
		if("change_image")
			change_image(usr)
			return TRUE
		if("check_dna")
			check_dna(usr)
			return TRUE
		if("crew_manifest")
			check_if_installed("crew manifest")
			ai_roster()
			return TRUE
		if("door_jack")
			check_if_installed("door jack")
			door_jack(usr, params["jack"])
			return TRUE
		if("encryption_keys")
			check_if_installed("encryption keys")
			to_chat(src, span_notice("You have [!encrypt_mod ? "enabled" \
				: "disabled"] encrypted radio frequencies."))
			encrypt_mod = !encrypt_mod
			radio.subspace_transmission = !radio.subspace_transmission
			return TRUE
		if("host_scan")
			check_if_installed("host scan")
			host_scan(usr)
			return TRUE
		if("internal_gps")
			check_if_installed("internal gps")
			if(!internal_gps)
				internal_gps = new(src)
			internal_gps.attack_self(src)
			return TRUE
		if("loudness_booster")
			check_if_installed("loudness booster")
			if(!internal_instrument)
				internal_instrument = new(src)
			internal_instrument.interact(src) // Open Instrument
			return TRUE
		if("medical_hud")
			check_if_installed("medical hud")
			toggle_hud(usr, "medical")
			return TRUE
		if("newscaster")
			check_if_installed("newscaster")
			newscaster.ui_interact(src)
			return TRUE
		if("photography_module")
			check_if_installed("photography module")
			aicamera.toggle_camera_mode(usr)
			return TRUE
		if("printer_module")
			check_if_installed("printer module")
			aicamera.paiprint(usr)
			return TRUE
		if("radio")
			check_if_installed("radio")
			radio.attack_self(src)
			return TRUE
		if("refresh")
			refresh_records(ui, params["list"])
			return TRUE
		if("remote_signaler")
			check_if_installed("remote signaler")
			signaler.ui_interact(src)
			return TRUE
		if("security_hud")
			check_if_installed("security hud")
			toggle_hud(usr, "security")
			return TRUE
		if("universal_translator")
			check_if_installed("universal translator")
			grant_languages(usr, ui)
			return TRUE
	return FALSE

/**
 * Purchases the selected software from the list and deducts their
 * available ram.
 *
 * @param user {mob} The user purchasing the software.
 * @param selection {string} The software to purchase.
 * @return {bool} TRUE if the software was purchased, FALSE otherwise.
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
	return TRUE

/**
 * Changes the image displayed on the pAI.
 *
 * @param user {silicon/pai} The user who is changing the image.
 * @return {bool} TRUE if the image was changed, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/change_image(mob/living/silicon/pai/user)
	var/new_image = tgui_input_list(user, "Select your new display image", \
		"Display Image", sort_list(list("Happy", "Cat", "Extremely Happy", \
		"Face",	"Laugh", "Off", "Sad", "Angry", "What", "Sunglasses", "None")))
	if(isnull(new_image))
		return FALSE
	switch(new_image)
		if("None")
			user.card.emotion_icon = "null"
		if("Extremely Happy")
			user.card.emotion_icon = "extremely-happy"
		else
			user.card.emotion_icon = "[lowertext(new_image)]"
	user.update_appearance()
	return TRUE

/**
 * Supporting proc for the pAI to prick it's master's hand
 * or... whatever. It must be held in order to work
 * Gives the owner a popup if they want to get the jab.
 *
 * @param user {mob} The pAI requesting the sample.
 * @param master {living/carbon} The holder of the pAI.
 * @return {boolean} TRUE if a sample was taken, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/check_dna(mob/living/silicon/pai/user)
	var/mob/living/carbon/holder
	if(holoform && istype(loc, /obj/item/clothing/head/mob_holder))
		holder = loc.loc
	if(!holoform && !iscarbon(loc))
		holder = loc
	if(!holder || !iscarbon(holder))
		to_chat(user, span_warning("You must be in someone's hands to do this!"))
		return FALSE
	to_chat(user, span_notice("Requesting a DNA sample."))
	if(tgui_alert(holder, "[user] is requesting a DNA sample from you. \
		Will you allow it to confirm your identity?", "Checking DNA", \
		list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("[holder] does not seem like [holder.p_theyre()] \
			going to provide a DNA sample willingly."))
		return FALSE
	holder.visible_message(span_notice("[holder] presses [holder.p_their()] \
		thumb against [user]."), span_notice("You press your thumb against \
		[user]."), span_notice("[user] makes a sharp clicking sound as it \
		extracts DNA material from [holder]."))
	if(!holder.has_dna())
		to_chat(user, span_warning("No DNA detected."))
		return FALSE
	to_chat(user, span_boldannounce(("[holder]'s UE string: [holder.dna.unique_enzymes]")))
	to_chat(user, span_notice("DNA [holder.dna.unique_enzymes == user.master_dna ? \
		"matches" : "does not match"] our stored Master's DNA."))
	return TRUE

/**
 * Error handler that catches pAIs attempting to use software
 * that hasn't been installed yet.
 *
 * @param user {mob} The pAI attempting to use the software.
 * @param selection {string} The software being used.
 * @return {bool} TRUE if the pAI was warned, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/check_if_installed(mob/user, selection)
	if(installed_software[selection])
		return TRUE
	to_chat(user, span_warning("You do not have atmosphere sensor installed."))
	stack_trace("[user] attempted to activate software they hadn't installed: [selection]")
	return FALSE

/**
 * Switch that handles door jack operations.
 *
 * @param user {silicon/pai} The user operating the door jack.
 * @param jack_state {string} The requested state of the door jack.
 * @return {bool} TRUE if the door jack state was switched, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/door_jack(mob/living/silicon/pai/user, jack_state)
	switch(jack_state)
		if("cable")
			extend_cable(user)
			return TRUE
		if("cancel")
			QDEL_NULL(hacking_cable)
			visible_message(span_notice("The cable retracts into the pAI."))
			return TRUE
		if("jack")
			if(!hacking_cable?.machine)
				to_chat(user, span_warning("You must be connected to a machine to do this."))
				return FALSE
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
 * @param user {mob} The pAI dropping the cable
 * @return {bool} TRUE if the cable was dropped, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/extend_cable(mob/user)
	QDEL_NULL(hacking_cable) //clear any old cables
	hacking_cable = new
	var/mob/living/hacker = user.loc
	if(isliving(hacker) && hacker.put_in_hands(hacking_cable))
		hacker.visible_message(span_warning("A port on [user] opens to reveal \a [hacking_cable], \
			which you quickly grab hold of."), span_hear("You hear the soft click of a plastic  \
			component and manage to catch the falling [hacking_cable]."))
		return TRUE
	hacking_cable.forceMove(drop_location())
	hacking_cable.visible_message(span_warning("A port on [user] opens to reveal \a [hacking_cable], \
		which promptly falls to the floor."), span_hear("You hear the soft click of a plastic component \
		fall to the ground."))
	return TRUE

/**
 * Grant all languages to the current pAI.
 *
 * @param user {mob} The pAI receiving the languages.
 * @param ui {tgui} The interface for the pAI.
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
 * After a 10 second timer, the door will crack open, provided they don't move out of the way.
 *
 * @return {bool} TRUE if the door was jacked, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/hack_door(mob/user)
	playsound(user, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
	balloon_alert(user, "overriding...")
	// Now begin hacking
	if(!do_after(src, 10 SECONDS, hacking_cable.machine, timed_action_flags = NONE, progress = TRUE))
		balloon_alert(user, "failed! retracting...")
		hacking_cable.visible_message(
			span_warning("[hacking_cable] rapidly retracts back into its spool."),\
			span_hear("You hear a click and the sound of wire spooling rapidly."))
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
 * Host scan supporting proc
 *
 * Allows the pAI to scan its host's health vitals
 * An integrated health analyzer.
 *
 * @param user {silicon/pai} The pAI requesting the scan.
 * @return {boolean} TRUE if the scan was successful, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/host_scan(mob/living/silicon/pai/user, scan_type)
	if(!host_scan)
		host_scan = new(src)
	if(!iscarbon(user.loc))
		to_chat(user, span_warning("You are not being carried by anyone!"))
		return FALSE
	user.host_scan.attack(user.loc, user)
	return TRUE

/**
 * Refreshes records on screen of the pAI.
 *
 * @param ui {tgui} The interface for the pAI.
 * @param list {string} The list of records to refresh.
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
 * @param user {silicon/pai} The pAI toggling the hud. *
 * @param option {string} The hud to toggle.
 */
/mob/living/silicon/pai/proc/toggle_hud(mob/living/silicon/pai/user, option)
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
